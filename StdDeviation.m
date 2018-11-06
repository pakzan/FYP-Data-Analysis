function StdDeviation()
    %get directory info
    path = 'Beetle 1/';
    folder = {'right_top/', 'right_mid/', 'right_bot/', 'left_top/', 'left_mid/', 'left_bot/'};
    
    %loop all folders
    for j = 1:length(folder)
        dinfo = dir(strcat(path, char(folder(j)), '*.txt'));
        val_change = zeros(length(dinfo), 6);    
        %loop all files
        for i = 1:length(dinfo)
            %get current file
            fprintf('Openning file %s\n', dinfo(i).name);
            filename = dinfo(i).name;
            var = load(strcat(path, char(folder(j)), filename));

            %smooth data
            var = smoothData(var);
            %get the value change for each trail
            val_change(i, :) = getStimulPointValue(var);
        end
        %save data
        save(strcat(path, char(folder(j)), 'stdDeviation.mat'), 'val_change'); 
        fprintf('Successfully saved %s\n\n', char(folder(j)));
    end
end

function var = smoothData(var)
    %smoothen x, y, rotation
    for i = 2:size(var,2)-1
        var(:,i) = smooth(var(:,1),var(:,i),0.3,'rloess');
    end
    
    %convert degree to radian    
    var(:,3) = deg2rad(var(:,3));
    var(:,6) = deg2rad(var(:,6));
end

function val_change = getStimulPointValue(var)
    %get the total changes in value for each stimulation for displacement and velocity of X, Y, Rotation
    val_change = zeros(1, 6);
    stimul_pnts = getStimulPoints(var);
    start_pnt = stimul_pnts(1);
    end_pnt = stimul_pnts(end);
    
    for type = 2:7
        if abs(min(var(start_pnt:end_pnt, type))) < max(var(start_pnt:end_pnt, type))
            maxmin = max(var(start_pnt:end_pnt, type));
        else
            maxmin = min(var(start_pnt:end_pnt, type));
        end
        val_change(type-1) = maxmin - var(start_pnt, type);
    end
        
end

function pnts = getStimulPoints(var)
    %1 sec tolerance
    tolerance = 1000;
    %stimulation from 5 sec to 10 sec
    start_time = 5000;
    end_time = 10000;
    
    %index of respective time
    start_pnt = find(var(:,1) > start_time - tolerance, 1);
    end_pnt = find(var(:,1) > end_time + tolerance, 1);
    
    piezo = var(:,8);
    stimul_pnts = find(piezo(start_pnt:end_pnt,1)>0.2);
    
    %get index of time
    if (size(stimul_pnts, 1) >= 2)
        pnts = start_pnt + stimul_pnts(1) : start_pnt + stimul_pnts(end);
    else
        %if stimul_pnts still has no value, set default pnts        
        start_pnt = find(var(:,1) > start_time, 1);
        end_pnt = find(var(:,1) > end_time, 1);
        pnts = start_pnt : end_pnt;
    end
end