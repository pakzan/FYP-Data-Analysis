%{
Author Name: TAN PAK ZAN
Date: 23/5/2019

This is a program that sort the beetle's 8 body parts into correct order:
left wing, left elytra, left leg, head, mesothorax, right leg, right elytra, right wing

First, the program sort the parts by distance. Point that has the minimum
distance with previous point is matched together under the same part.
Second, the program sort elytra and leg by absolute coordinate. Parts that
are lower and nearer to center are considered as legs.

Input value: 
FILENAME: name.csv of the input file
OUT_FILENAME: name.csv of the output file
TOLERANCE: tolerance values to filter the noise in distance or position sort
%}

function MarkerIdentifier_diff()
    global col_length
    global row_length
    global dimens
    global parts
    global TOLERANCE
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% user input value %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FILENAME = 'Trial 1.csv';
    OUT_FILENAME = strcat('Sorted', FILENAME);
    TOLERANCE = [4, 4]; % tolerance for [distance sort, position sort]
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% load mat from raw csv %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ignore first 5 rows and first 2 columns
    offset = [5, 2];
    var = csvread(FILENAME, offset(1), offset(2));
    var(var == 0) = NaN;    
    
%      var = importdata('test.csv');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get/set general variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [col_length, row_length] = size(var);
    dimens = 3;
    parts = row_length / dimens;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% main function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    var = organiseArr(var);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot graph %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off
    
    for part = 0:parts-1
        xyz = [part*3 + 1, part*3 + 2, part*3 + 3];

        % ignore nan variables
        idxs = ~isnan(var(:, xyz(1)));
        idys = ~isnan(var(:, xyz(2)));
        idzs = ~isnan(var(:, xyz(3)));

        plot3(var(idxs, xyz(1)), var(idys, xyz(2)), var(idzs, xyz(3)));
        hold on
    end
    grid on
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% save csv file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    csvwrite(OUT_FILENAME, var);
%     save('classify_var.mat', 'classify_var');
end

function org_var = organiseArr(var)
    global col_length
    global row_length
    global parts
    global filter_no
    
    filter_no = 0;
    sample = 20;
    prev_dist = 20*ones(parts, sample);
    org_var = nan(col_length, row_length);
    
    % sort 1st row by x in descending order
    % left wing, left elytra, left leg, head, mesothorax, right leg, right elytra, right wing
    org_var(1,:) = sortRow(var(1, :));        
    % convert 1d array to 2d array (x, y, z)
    prev_row_2d = reshape_1to2(org_var(1, :));
    
    % sort by parts' distance
    for row_ind = 1:col_length
        row_2d = reshape_1to2(var(row_ind, :));
        [prev_row_2d, row_2d, prev_dist] = organiseRow(row_ind, prev_row_2d, row_2d, prev_dist);
        org_var(row_ind, :) = reshape_2to1(row_2d);
    end
    
    % sort whole var to make sure elytra and leg in correct position
    org_var = resortArr(org_var);
    % check if elytra and leg collide with each other
    collide = checkCollide(org_var);
    
    % sort by parts' position if collided
    if any(collide)
        prev_dist = 20*ones(parts, sample);
        prev_row_2d = reshape_1to2(org_var(1, :));
        for row_ind = 1:col_length
            row_2d = reshape_1to2(org_var(row_ind, :));
            [prev_row_2d, row_2d, prev_dist] = organiseRow2(row_ind, prev_row_2d, row_2d, prev_dist, collide);
            org_var(row_ind, :) = reshape_2to1(row_2d);
        end
    end
    fprintf('Total points: %d\nFiltered points: %d\nFiltered Percentage: %f%%\n', col_length*parts, filter_no, 100*filter_no/(col_length*parts));      
end

function [prev_row, org_row, prev_dist] = organiseRow(abs_row, prev_row, row, prev_dist)
    global dimens
    global parts
    global filter_no
    global TOLERANCE

    % calculate the (x, y, z) distance for all parts    
    % between prev_row and row
    dist = zeros(parts, parts);
    for part = 1:parts
        for temp_part = 1:parts
        	dist(part, temp_part) = norm(row(temp_part, :) - prev_row(part, :)) + abs(row(temp_part, 1) - prev_row(part, 1));
        end
    end
        
    % reorganise the parts
    org_row = nan(parts, dimens);
    while any(~isnan(dist(:)))
        % find the minimum (x, y, z) distance for all parts 
        [~, ind] = min(dist(:));
        [ind_row, ind_col] = ind2sub(size(dist), ind);
                
        org_row(ind_row, :) = row(ind_col, :);
        
        % replace used column and row to nan
        dist(ind_row, :) = nan;
        dist(:, ind_col) = nan;
    end
    
    % update current and previous row
    for part = 1:parts
        % update if distance within tolerance, else set current part to nan
        cur_dist = norm(prev_row(part, :) - org_row(part, :)) + abs(prev_row(part, 1) - org_row(part, 1));
        if any(~isnan(org_row(part, :)))
            if (part == 1 && org_row(1, 1) > prev_row(1, 1)) || ...
                    (part == parts && org_row(parts, 1) < prev_row(parts, 1)) || ...
                        cur_dist < mean(prev_dist(part,:)) * TOLERANCE(1)
                prev_row(part, :) = org_row(part, :);
                
                % dont update prev_dist if cur_dist too small
                if cur_dist > 1
                    prev_dist(part, :) = [prev_dist(part, 2:end) cur_dist];
                end
            else
                filter_no = filter_no+1;
                fprintf('Position exceeded tolerance! Row: %d, Col: %d - %d\n',...
                            abs_row, 3*(part-1) + 1, 3*(part-1) + 3);      
                org_row(part, :) = nan;
            end
        end
    end    
end



function [prev_row, org_row, prev_dist] = organiseRow2(abs_row, prev_row, org_row, prev_dist, collide)
    global filter_no
    global TOLERANCE
    
    % reorganise 2nd and 3rd part if they collided
    if collide(1) && org_row(2, 1) + org_row(2, 3) < org_row(3, 1) + org_row(3, 3)
        [org_row(2,:), org_row(3,:)] = deal(org_row(3,:), org_row(2,:));
    end

    % reorganise 6th and 7th part if they collided
    if collide(2) && org_row(6, 1) - org_row(6, 3) < org_row(7, 1) - org_row(7, 3)
        [org_row(6,:), org_row(7,:)] = deal(org_row(7,:), org_row(6,:));
    end
    
    % update current and previous row
    for part = [2,3,6,7]
        % update if distance within tolerance, else set current part to nan
        cur_dist = norm(prev_row(part, :) - org_row(part, :));
        if any(~isnan(org_row(part, :)))
            if cur_dist < mean(prev_dist(part,:)) * TOLERANCE(2)
                prev_row(part, :) = org_row(part, :);
                
                % dont update prev_dist if cur_dist too small
                if cur_dist > 1
                    prev_dist(part, :) = [prev_dist(part, 2:end) cur_dist];
                end
            else
                filter_no = filter_no+1;
                fprintf('Position exceeded tolerance! Row: %d, Col: %d - %d\n',...
                            abs_row, 3*(part-1) + 1, 3*(part-1) + 3);      
                org_row(part, :) = nan;
            end
        end
    end    
end

function collide = checkCollide(var)
    % left elytra(2nd part) and left leg(3rd part)
    x1_max = max(var(:,4:6));
    x2_max = max(var(:,7:9));     
    % right elytra(6th part) and right leg(7th part)
    x1_min = min(var(:,16:18));
    x2_min = min(var(:,19:21));
    
    % check if their extreme x position are nearby
    collide = [abs(x1_max(1) - x2_max(1)) < 1, abs(x1_min(1) - x2_min(1)) < 1];
end

function var = resortArr(var)
    L_ely = mean(var(:,4:6));
    L_leg = mean(var(:,7:9));
    % left elytra before left leg (2nd and 3rd part)
    if L_ely(1) + L_ely(3) < L_leg(1) + L_leg(3)
        [var(:, 4:6), var(:, 7:9)] = deal(var(:, 7:9), var(:, 4:6));
    end
    
    R_ely = mean(var(:,16:18));
    R_leg = mean(var(:,19:21));
    % right leg before right elytrax (6th and 7th part)
    if R_ely(1) - R_ely(3) < R_leg(1) - R_leg(3)
        [var(:, 16:18), var(:, 19:21)] = deal(var(:, 19:21), var(:, 16:18));
    end
end

function sorted_row = sortRow(row)
    global row_length
    global parts
    
    sorted_row = nan(1, row_length);    
    parts_x = nan(parts, 2);
    
    %get x value from each part
    for part = 0:parts-1
        x = part*3 + 1;
        parts_x(part+1,:) = [row(x), x];
    end
    
    %sort parts by x (descending order)
    parts_x = sortrows(parts_x,-1);
    
    %reorganise row according to sorted parts_x
    for part = 0:parts-1
        x = part*3 + 1;
        sorted_x = parts_x(part+1,2);
        sorted_row(x:x+2) = row(sorted_x:sorted_x+2);
    end
    
    % head before mesothorax (4th and 5th part)
    if sorted_row(12) > sorted_row(15)
        [sorted_row(10:12), sorted_row(13:15)] = deal(sorted_row(13:15), sorted_row(10:12));
    end
end

function row = reshape_2to1(row_2d)
    global row_length
    
    % reshape 2d row to 1d row
    row = reshape(transpose(row_2d), 1, row_length);
end

function row_2d = reshape_1to2(row)
    global dimens
    global parts
    
    % reshape 1d row to 2d row
    row_2d = transpose(reshape(row, dimens, parts));
end
