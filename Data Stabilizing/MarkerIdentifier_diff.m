function MarkerIdentifier_diff()
    global col_length
    global row_length
    global dimens
    global parts
    global tolerance
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% load mat from raw csv %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ignore first 5 rows and first 2 columns
    filename = 'Trial 9.csv';
    offset = [5, 2];
    var = csvread(filename, offset(1), offset(2));
    var(var == 0) = NaN;
    
%      var = importdata('test.csv');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get/set general variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [col_length, row_length] = size(var);
    dimens = 3;
    parts = row_length / dimens;
    
    % set tolerance to obtain clean result
    % tolerance = [refining row, record prev_row, include to sample]
    tolerance = [2, 20, 20];
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% main function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    var = organiseArr(var, var);
%     var = seperateArr(var);
    
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
    
%     save('classify_var.mat', 'classify_var');
end


function org_var = seperateArr(var)
    global col_length
    global row_length
    global parts
        
    %sort by mean x    
%     for row_ind = 1:col_length
%         mean_x = nan(parts, 2);
%         if ~any(isnan(var(row_ind, :)))
%             for part = 0:parts-1
%                 x = part*3 + 1;
%                 mean_x(part+1,:) = [var(row_ind, x), x];
%             end   
%             mean_x = sortrows(mean_x,-1);
%             for part = 0:parts-1
%                 xyz = [part*3 + 1, part*3 + 2, part*3 + 3];
%                 sorted_xyz = [mean_x(part+1,2), mean_x(part+1,2)+1, mean_x(part+1,2)+2];
%                 org_var(row_ind,xyz(1):xyz(3)) = var(row_ind,sorted_xyz(1):sorted_xyz(3));
%             end
%         else
%             org_var(row_ind,:) = org_var(row_ind-1,:);
%         end
%     end
                
    org_var = var;
%     prev_row = org_var(1, :);
%     x1_max = max(org_var(:,4:6));
%     x2_max = max(org_var(:,7:9));
%     if abs(x1_max(1) - x2_max(1)) < 1        
%         for row_ind = 2:col_length
%             %rearrange left 2 positions
%             if org_var(row_ind, 4) + org_var(row_ind, 6) < org_var(row_ind, 7) + org_var(row_ind, 9)
%                 if norm(prev_row(7:9) - org_var(row_ind, 4:6))>20
%                     org_var(row_ind, 4:6) = nan(1, 3);
%                 else
%                     prev_row(7:9) = org_var(row_ind, 4:6);
%                 end
%                 if norm(prev_row(4:6) - org_var(row_ind, 7:9))>20
%                     org_var(row_ind, 7:9) = nan(1, 3);
%                 else
%                     prev_row(4:6) = org_var(row_ind, 7:9);
%                 end
%                 [org_var(row_ind, 4:6), org_var(row_ind, 7:9)] = deal(org_var(row_ind, 7:9), org_var(row_ind, 4:6));
%             end
%         end
%     end
%     x1_min = min(org_var(:,16:18));
%     x2_min = min(org_var(:,19:21));
%     if abs(x1_min(1) - x2_min(1)) < 1        
%         for row_ind = 2:col_length
%             %rearrange right 2 positions
%             if org_var(row_ind, 16) - org_var(row_ind, 18) < org_var(row_ind, 19) - org_var(row_ind, 21)
%                 if norm(prev_row(19:21) - org_var(row_ind, 16:18))>20
%                     org_var(row_ind, 16:18) = nan(1, 3);
%                 else
%                     prev_row(19:21) = org_var(row_ind, 16:18);
%                 end
%                 if norm(prev_row(16:18) - org_var(row_ind, 19:21))>20
%                     org_var(row_ind, 19:21) = nan(1, 3);
%                 else
%                     prev_row(16:18) = org_var(row_ind, 19:21);
%                 end
%                 [org_var(row_ind, 16:18), org_var(row_ind, 19:21)] = deal(org_var(row_ind, 19:21), org_var(row_ind, 16:18));
%             end
%         end
%     end
%     for row_ind = 1:col_length
%         %rearrange middle 2 positions
%         if org_var(row_ind, 11) < org_var(row_ind, 14)
%             temp = org_var(row_ind, 10:12);
%             org_var(row_ind, 10:12) = org_var(row_ind, 13:15);
%             org_var(row_ind, 13:15) = temp;
%         end
%         
%         %rearrange left 2 positions
%         if org_var(row_ind, 4) + org_var(row_ind, 6) < org_var(row_ind, 7) + org_var(row_ind, 9)            
%             [org_var(row_ind, 4:6), org_var(row_ind, 7:9)] = deal(org_var(row_ind, 7:9), org_var(row_ind, 4:6));
%         end
%         
%         %rearrange right 2 positions
%         if org_var(row_ind, 16) - org_var(row_ind, 18) < org_var(row_ind, 19) - org_var(row_ind, 21)
%             [org_var(row_ind, 16:18), org_var(row_ind, 19:21)] = deal(org_var(row_ind, 19:21), org_var(row_ind, 16:18));
%         end
%     end
end

function org_var = organiseArr(var1, var)
    global col_length
    global row_length
    global dimens
    global parts
    
    sample = 20;
    speed = 20*ones(parts, sample);
    
    mean_x = nan(parts, 2);
    for part = 0:parts-1
        x = part*3 + 1;
        mean_x(part+1,:) = [var(1, x), x];
    end   
    mean_x = sortrows(mean_x,-1);
    for part = 0:parts-1
        xyz = [part*3 + 1, part*3 + 2, part*3 + 3];
        sorted_xyz = [mean_x(part+1,2), mean_x(part+1,2)+1, mean_x(part+1,2)+2];
        var(1,xyz(1):xyz(3)) = var1(1,sorted_xyz(1):sorted_xyz(3));
    end
        
    % convert 1d array to 2d array (x, y, z)
    prev_row_2d = reshape_1to2(var(1, :));
    
    
    % sort and store value to new_var
    org_var = nan(col_length, row_length);
    
%     sample = 20;
%     samp_row = nan(sample, parts, dimens);
%     for ind = 1:sample
%         row_ind = randi([1 col_length],1);
%         samp_row(ind, :, :) = reshape_1to2(var1(row_ind, :));
%     end
   
    for row_ind = 1:col_length
        row_2d = reshape_1to2(var(row_ind, :));
        [prev_row_2d, row_2d, speed] = organiseRow(row_ind, prev_row_2d, row_2d, speed);
        org_var(row_ind, :) = reshape_2to1(row_2d);
    end
    
    x1_max = max(org_var(:,4:6));
    x2_max = max(org_var(:,7:9)); 
    
    x1_min = min(org_var(:,16:18));
    x2_min = min(org_var(:,19:21));
    arrange = [abs(x1_max(1) - x2_max(1)) < 1, abs(x1_min(1) - x2_min(1)) < 1];
    
    prev_row_2d = reshape_1to2(var(1, :));
    if any(arrange)
        for row_ind = 1:col_length
            row_2d = reshape_1to2(var(row_ind, :));
            [prev_row_2d, row_2d, speed] = organiseRow2(row_ind, prev_row_2d, row_2d, speed, arrange);
            org_var(row_ind, :) = reshape_2to1(row_2d);
        end
    end
end

function [prev_row, org_row, speed] = organiseRow(abs_row, prev_row, row, speed)
    global dimens
    global parts
    global tolerance

    % calculate the (x, y, z) distance for all parts    
    % between prev_row and row
    dist = zeros(parts, parts);
    for part = 1:parts
        for temp_part = 1:parts
        	dist(part, temp_part) = norm(row(temp_part, :) - prev_row(part, :)) + abs(row(temp_part, 1) - prev_row(part, 1));
        end
    end
    
%     dist = zeros(parts, parts);
%     for part = 1:parts
%         for temp_part = 1:parts
%             dist(part, temp_part) = norm(row(temp_part, :) - [samp_row(1, part, 1), samp_row(1, part, 2), samp_row(1, part, 3)]);
%             for ind = 2:sample
%                 dist(part, temp_part) = min(dist(part, temp_part), norm(row(temp_part, :) - [samp_row(ind, part, 1), samp_row(ind, part, 2), samp_row(ind, part, 3)]));
%             end
%         end
%     end
    
    % reorganise the parts
    org_row = nan(parts, dimens);
    while any(~isnan(dist(:)))
        % find the minimum (x, y, z) distance for all parts 
        [minval, ind] = min(dist(:));
        [ind_row, ind_col] = ind2sub(size(dist), ind);
                
        org_row(ind_row, :) = row(ind_col, :);
        
        % replace used column and row to nan
        dist(ind_row, :) = nan;
        dist(:, ind_col) = nan;
    end
    
%     if norm(prev_row(1, :) - org_row(1, :)) + norm(prev_row(2, :) - org_row(2, :)) > norm(prev_row(1, :) - org_row(2, :)) + norm(prev_row(2, :) - org_row(1, :))
%         [org_row(1, :), org_row(2, :)] = deal(org_row(2, :), org_row(1, :));
%     end
%     if norm(prev_row(1, :) - org_row(1, :)) + norm(prev_row(3, :) - org_row(3, :)) > norm(prev_row(1, :) - org_row(3, :)) + norm(prev_row(3, :) - org_row(1, :))
%         [org_row(1, :), org_row(3, :)] = deal(org_row(3, :), org_row(1, :));
%     end

%     if org_row(1, 1) < org_row(2, 1)
%         [org_row(1, :), org_row(2, :)] = deal(org_row(2, :), org_row(1, :));
%     end
%     if org_row(1, 1) < org_row(3, 1)
%         [org_row(1, :), org_row(3, :)] = deal(org_row(3, :), org_row(1, :));
%     end
    
    %update previous row
    for part = 1:parts
        cur_dist = norm(prev_row(part, :) - org_row(part, :)) + abs(prev_row(part, 1) - org_row(part, 1));
        if any(~isnan(org_row(part, :))) && cur_dist < mean(speed(part,:)) * 4;
            prev_row(part, :) = org_row(part, :);
            if cur_dist > 1
                speed(part, :) = [speed(part, 2:end) cur_dist];
            end
        else
            fprintf('Position exceeded tolerance! Row: %d, Col: %d - %d\n',...
                        abs_row, 3*(part-1) + 1, 3*(part-1) + 3);      
            org_row(part, :) = nan;
        end
    end    
end



function [prev_row, org_row, speed] = organiseRow2(abs_row, prev_row, row, speed, arrange)
    global dimens
    global parts
    global tolerance

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
        [minval, ind] = min(dist(:));
        [ind_row, ind_col] = ind2sub(size(dist), ind);
                
        org_row(ind_row, :) = row(ind_col, :);
        
        % replace used column and row to nan
        dist(ind_row, :) = nan;
        dist(:, ind_col) = nan;
    end
    
    if arrange(1) && org_row(2, 1) + org_row(2, 3) < org_row(3, 1) + org_row(3, 3)
        [org_row(2,:), org_row(3,:)] = deal(org_row(3,:), org_row(2,:));
    end

    if arrange(2) && org_row(6, 1) - org_row(6, 3) < org_row(7, 1) - org_row(7, 3)
        [org_row(6,:), org_row(7,:)] = deal(org_row(7,:), org_row(6,:));
    end
    
    %update previous row
    for part = 1:parts
        cur_dist = norm(prev_row(part, :) - org_row(part, :)) + abs(prev_row(part, 1) - org_row(part, 1));
        if any(~isnan(org_row(part, :))) && cur_dist < mean(speed(part,:)) * 4;
            prev_row(part, :) = org_row(part, :);
            if cur_dist > 1
                speed(part, :) = [speed(part, 2:end) cur_dist];
            end
        else
            fprintf('Position exceeded tolerance! Row: %d, Col: %d - %d\n',...
                        abs_row, 3*(part-1) + 1, 3*(part-1) + 3);      
            org_row(part, :) = nan;
        end
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
