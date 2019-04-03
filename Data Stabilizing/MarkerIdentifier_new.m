function MarkerIdentifier_new()
    global col_length
    global row_length
    global dimen
    global parts
    
    % load mat from csv
    var = importdata('test.csv');
    
    col_length = size(var,1);
    row_length = size(var,2);
    dimen = 3;
    parts = row_length / dimen;
    
    var = getSortedArr(var);
    
    
    for part = 0:parts-1
        xyz = [part*3 + 1, part*3 + 2, part*3 + 3];
        idxs = ~isnan(var(:, xyz(1)));
        idys = ~isnan(var(:, xyz(2)));
        idzs = ~isnan(var(:, xyz(3)));
        
        plot3(var(idxs, xyz(1)), var(idys, xyz(2)), var(idzs, xyz(3)));
        hold on
    end
%     plot3(var(:,4),var(:,5),var(:,6))
%     hold on
%     plot3(var(:,7),var(:,8),var(:,9))
%     hold on
%     plot3(var(:,10),var(:,11),var(:,12))
%     hold on
%     plot3(var(:,13),var(:,14),var(:,15))
%     hold on
%     plot3(var(:,16),var(:,17),var(:,18))
%     hold on
%     plot3(var(:,19),var(:,20),var(:,21))
%     hold on
%     plot3(var(:,22),var(:,23),var(:,24))
%     hold on
    
    grid on
end

% function empty_row = getEmptyRow(var)
%     empty_row = -1;
%     
%     % get row that consistt nan
%     for row = 1:row_length
%         if sum(isnan(var(row,:))) > 0
%             empty_row(end+1) = row;
%         end
%     end
%     
%     % remove first element
%     if size(empty_row, 1) > 1
%         empty_row = empty_row(2:);
%     end
% end

function sorted_row = getSortedRow(row)
    global dimen
    global parts
    
    tolerance = 10;
    % convert 1d array to 2d array (x, y, z)
    row_2d = transpose(reshape(row, dimen, parts));
    
    % sort 1st column (x)
    sorted_row = sortrows(row_2d, 1);
    
    % sort 2nd column (y) if previous column (x) has similar value
    col = 2;
    prev_row = 1;
    should_sort = false;
    for row = 1:parts-1
        % get value difference of previous column
        row_val_dif = abs(sorted_row(row, col-1) - sorted_row(row+1, col-1));
        if ~should_sort && row_val_dif <= tolerance
            prev_row = row;
            should_sort = true;
        elseif should_sort
            sorted_row(prev_row:row, :) = sortrows(sorted_row(prev_row:row, :), col);
            prev_row = row;
            should_sort = false;
        end
    end
    
    % sort 3rd column (z) if previous columns (x, y) has similar value
    col = 3;
    prev_row = 1;
    should_sort = false;
    for row = 1:parts-1
        % get value difference of previous columns
        row_val_dif = abs(sorted_row(row, col-2) - sorted_row(row+1, col-2)) ...
                        + abs(sorted_row(row, col-1) - sorted_row(row+1, col-1));
        if ~should_sort && row_val_dif <= tolerance
            prev_row = row;
            should_sort = true;
        elseif should_sort
            sorted_row(prev_row:row, :) = sortrows(sorted_row(prev_row:row, :), col);
            prev_row = row;
            should_sort = false;
        end
    end    
end

function [prev_row, row] = organiseArr(prev_row, row)
    global dimen
    global parts
    
    % find where the NaNs belong to
    for part = 1:parts-1
        % if found all parts, break the loop
        if sum(isnan(row(end, :))) < 3
            break;
        end
        % check if current part (x, y, z) difference is larger than next part
        dif = 0;
        next_dif = 0;
        for pos = 1:dimen
            dif = dif + abs(row(part, pos) - prev_row(part, pos));
            next_dif = next_dif + abs(row(part, pos) - prev_row(part+1, pos));
        end
        % shift part to right
        if dif > next_dif
            row(part:end, :) = [nan(1, 3); row(part:end-1, :)];
        end
    end
    
    %update previous row
    for part = 1:parts
        for pos = 1:dimen
            if ~isnan(row(part, pos))
                prev_row(part, pos) = row(part, pos);
            end
        end
    end
end

function sorted_var = getSortedArr(var)
    global col_length
    global row_length
    global dimen
    global parts
    
    % convert 1d array to 2d array (x, y, z)
    prev_row_2d = transpose(reshape(var(1,:), dimen, parts));
    prev_row_2d = getSortedRow(prev_row_2d);
    
    % sort and story value to new_var
    sorted_var = nan(col_length, row_length);
    for row_ind = 1:col_length
        row = var(row_ind, :);
        [prev_row_2d, row] = organiseArr(prev_row_2d, getSortedRow(row));
        sorted_var(row_ind, :) = reshape(transpose(row), 1, row_length);
    end
end


