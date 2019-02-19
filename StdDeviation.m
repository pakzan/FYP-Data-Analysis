function StdDeviation()
    %get directory info
    paths = {'Beetle 4 (44_23)/', 'Beetle 5 (36_25)/', 'Beetle 6 (52_24)/', 'Beetle 7 (49_25)/', 'Beetle 8 (44_22)/', 'Beetle 9 (47_25)/'};
    folder = {'right top/', 'right mid/', 'right bot/', 'left top/', 'left mid/', 'left bot/'};
    
    for path_i = 1:length(paths)
        path = char(paths(path_i));
        %loop all folders
        for j = 1:length(folder)
            dinfo = dir(strcat(path, char(folder(j)), '*.txt'));
            val_change = zeros(length(dinfo), 9);    
            %loop all files
            for i = 1:length(dinfo)
                %get current file
                fprintf('Openning file %s\n', dinfo(i).name);
                filename = dinfo(i).name;
                var = load(strcat(path, char(folder(j)), filename));

                %smooth data
                var = smoothData(var);

                %get acceleration
                var(:,11) = var(:,8);
                var(:,8:10) = getSmoothGrad(var(:,1), var(:,5:7));

                %get the value change for each trail
                val_change(i, :) = getStimulPointValue(var);
            end
            %save data
            save(strcat(path, char(folder(j)), 'stdDeviation.mat'), 'val_change'); 
            fprintf('Successfully saved %s\n\n', char(folder(j)));
        end
    end
end

function val_change = getStimulPointValue(var)
    %get the total changes in value for each stimulation for disp, vel and acc of X, Y, Rotation
    val_change = zeros(1, size(var, 2) - 2);
    stimul_pnts = getStimulPoints(var);
    start_pnt = stimul_pnts(1);
    end_pnt = stimul_pnts(end);
    
    for type = 2:size(var, 2) - 1
        if abs(min(var(start_pnt:end_pnt, type))) < max(var(start_pnt:end_pnt, type))
            maxmin = max(var(start_pnt:end_pnt, type));
        else
            maxmin = min(var(start_pnt:end_pnt, type));
        end
        val_change(type-1) = maxmin - var(start_pnt, type);
    end
        
end
