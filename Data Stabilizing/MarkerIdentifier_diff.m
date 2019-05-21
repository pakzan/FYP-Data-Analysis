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
    tolerance = [2, 200, 200];
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% main function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     var = organiseArr(var);
    var = seperateArr(var);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot graph %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off
    
    for part = 0:parts-1
        xyz = [part*3 + 1, part*3 + 2, part*3 + 3];

        % ignore nan variables
        idxs = ~isnan(var(:, xyz(1)));
        idys = ~isnan(var(:, xyz(2)));
        idzs = ~isnan(var(:, xyz(3)));

        plot3(var(idxs, xyz(1)), var(idys, xyz(2)), var(idzs, xyz(3)),'.');
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
    for row_ind = 1:col_length
        mean_x = nan(parts, 2);
        if ~any(isnan(var(row_ind, :)))
            for part = 0:parts-1
                x = part*3 + 1;
                mean_x(part+1,:) = [var(row_ind, x), x];
            end   
            mean_x = sortrows(mean_x,-1);
            for part = 0:parts-1
                xyz = [part*3 + 1, part*3 + 2, part*3 + 3];
                sorted_xyz = [mean_x(part+1,2), mean_x(part+1,2)+1, mean_x(part+1,2)+2];
                org_var(row_ind,xyz(1):xyz(3)) = var(row_ind,sorted_xyz(1):sorted_xyz(3));
            end
        else
            org_var(row_ind,:) = org_var(row_ind-1,:);
        end
    end
    
    
    %sort by mean x
%     mean_x = nan(parts, 2);
%     for part = 0:parts-1
%         x = part*3 + 1;
%         mean_x(part+1,:) = [nanmean(var(:, x)), x];
%     end   
%     mean_x = sortrows(mean_x,-1);
%     for part = 0:parts-1
%         xyz = [part*3 + 1, part*3 + 2, part*3 + 3];
%         sorted_xyz = [mean_x(part+1,2), mean_x(part+1,2)+1, mean_x(part+1,2)+2];
%         org_var(:,xyz(1):xyz(3)) = var(:,sorted_xyz(1):sorted_xyz(3));
%     end
%     
%     

%     for row_ind = 1:col_length
%         %rearrange left 2 positions
%         temp = org_var(row_ind, 1:3);
%         if org_var(row_ind, 4) > org_var(row_ind, 1)
%             org_var(row_ind, 1:3) = org_var(row_ind, 4:6);
%             org_var(row_ind, 4:6) = temp;
%         elseif org_var(row_ind, 7) > org_var(row_ind, 1)
%             org_var(row_ind, 1:3) = org_var(row_ind, 7:9);
%             org_var(row_ind, 7:9) = temp;
%         end
%         
%         %rearrange right 2 positions
%         temp = org_var(row_ind, 22:24);
%         if org_var(row_ind, 19) < org_var(row_ind, 22)
%             org_var(row_ind, 22:24) = org_var(row_ind, 19:21);
%             org_var(row_ind, 19:21) = temp;
%         elseif org_var(row_ind, 16) < org_var(row_ind, 22)
%             org_var(row_ind, 22:24) = org_var(row_ind, 16:18);
%             org_var(row_ind, 16:18) = temp;
%         end
%     end
    
    
    
    for row_ind = 1:col_length
        %rearrange middle 2 positions
        if org_var(row_ind, 11) < org_var(row_ind, 14)
            temp = org_var(row_ind, 10:12);
            org_var(row_ind, 10:12) = org_var(row_ind, 13:15);
            org_var(row_ind, 13:15) = temp;
        end
        
        %rearrange left 2 positions
        if org_var(row_ind, 4) + org_var(row_ind, 6) < org_var(row_ind, 7) + org_var(row_ind, 9)
            temp = org_var(row_ind, 4:6);
            org_var(row_ind, 4:6) = org_var(row_ind, 7:9);
            org_var(row_ind, 7:9) = temp;
        end
        
        %rearrange right 2 positions
        if org_var(row_ind, 16) - org_var(row_ind, 18) < org_var(row_ind, 19) - org_var(row_ind, 21)
            temp = org_var(row_ind, 16:18);
            org_var(row_ind, 16:18) = org_var(row_ind, 19:21);
            org_var(row_ind, 19:21) = temp;
        end
    end
    
%     left_edge = getLeftEdge([org_var(:,[4 5]); org_var(:,[7 8])]);
%     right_edge = getRightEdge([org_var(:,[16 17]); org_var(:,[19 20])]);    
%     top_edge = getTopEdge([org_var(:,[10 11]); org_var(:,[13 14])]);
%     
%     for row_ind = 1:col_length
%         %rearrange left 2 positions
%         y1 = (org_var(row_ind, 4)-left_edge(1))*(top_edge(2)-left_edge(2)) / (top_edge(1)-left_edge(1)) + left_edge(2);
%         y2 = (org_var(row_ind, 7)-left_edge(1))*(top_edge(2)-left_edge(2)) / (top_edge(1)-left_edge(1)) + left_edge(2);
%         if org_var(row_ind, 8) < y2 && org_var(row_ind, 5) > y1
%             temp = org_var(row_ind, 4:6);
%             org_var(row_ind, 4:6) = org_var(row_ind, 7:9);
%             org_var(row_ind, 7:9) = temp;
%         end
%         
%         %rearrange right 2 positions
%         y1 = (org_var(row_ind, 19)-right_edge(1))*(top_edge(2)-right_edge(2)) / (top_edge(1)-right_edge(1)) + right_edge(2);
%         y2 = (org_var(row_ind, 16)-right_edge(1))*(top_edge(2)-right_edge(2)) / (top_edge(1)-right_edge(1)) + right_edge(2);
%         if org_var(row_ind, 17) < y2 && org_var(row_ind, 20) > y1
%             temp = org_var(row_ind, 16:18);
%             org_var(row_ind, 16:18) = org_var(row_ind, 19:21);
%             org_var(row_ind, 19:21) = temp;
%         end
%     end
end

function top_edge = getTopEdge(var_xy)
    [~,I] = min(var_xy(:,2));
    top_edge = var_xy(I, :);
end

function left_edge = getLeftEdge(var_xy)
    [~,I] = max(sum(var_xy, 2));
    left_edge = var_xy(I, :);
end

function right_edge = getRightEdge(var_xy)
    var_xy(:,1) = -var_xy(:,1);
    [~,I] = max(sum(var_xy, 2));
    right_edge = [-var_xy(I, 1), var_xy(I, 2)];
end

function org_var = organiseArr(var)
    global col_length
    global row_length
    
    % convert 1d array to 2d array (x, y, z)
    prev_row_2d = reshape_1to2(var(col_length, :));
    
    % sort and store value to new_var
    org_var = nan(col_length, row_length);
   
    for row_ind = 1:col_length
        row_2d = reshape_1to2(var(row_ind, :));
        [prev_row_2d, row_2d] = organiseRow(row_ind, prev_row_2d, row_2d);
        org_var(row_ind, :) = reshape_2to1(row_2d);
    end
end

function [prev_row, org_row] = organiseRow(abs_row, prev_row, row)
    global dimens
    global parts
    global tolerance

hole1 = [-6, 38, 178];
hole2 = [-6, 37, 170];

    % calculate the (x, y, z) distance for all parts    
    % between prev_row and row
    dist = zeros(parts, parts);
    for part = 1:parts
        for temp_part = 1:parts
        	dist(part, temp_part) = norm(row(temp_part, :) - prev_row(part, :));
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
    
    
    %update previous row
    for part = 1:parts
        if any(~isnan(org_row(part, :))) && norm(prev_row(part, :) - org_row(part, :)) < tolerance(2) && norm(org_row(part, :) - hole1) > 0 && norm(org_row(part, :) - hole2) > 0
            prev_row(part, :) = org_row(part, :);
        end
        if norm(prev_row(part, :) - org_row(part, :)) > tolerance(3) || norm(org_row(part, :) - hole1) < 0 || norm(org_row(part, :) - hole2) < 0
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
