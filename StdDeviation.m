function StdDeviation()
    %get directory info
    path = 'Beetle 2/';
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

            %smooth data then calculate gradient
            grad = getGradient(smoothData(var));
            %get the value change for each trail
            val_change(i, :) = getStimulPointValue(var, grad);
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
    %filter and smoothen piezo
    piezo = var(:,8);
    piezo(piezo < 0.2) = 0;
    %var(:,8) = smooth(var(:,1),piezo,0.1,'rloess');
    
    %convert degree to radian    
    var(:,3) = deg2rad(var(:,3));
    var(:,6) = deg2rad(var(:,6));
end

function grad = getGradient(var)
    grad = var(1:size(var,1)-1,:);
    %get gradient of displacement and velocity of X, Y, Rotation
    for i = 2:7
        grad(:,i) = diff(var(:,i))./diff(var(:,1));
    end
end

function val_change = getStimulPointValue(var, grad)
    %get the total changes in value for each stimulation for displacement and velocity of X, Y, Rotation
    val_change = zeros(1, 6);
    start_pnt = getStimulPoint(5000, grad);
    end_pnt = getStimulPoint(10000, grad);
    
    for type = 2:7
        if abs(min(var(start_pnt:end_pnt, type))) < max(var(start_pnt:end_pnt, type))
            maxmin = max(var(start_pnt:end_pnt, type));
        else
            maxmin = min(var(start_pnt:end_pnt, type));
        end
        val_change(type-1) = maxmin - var(start_pnt, type);
    end
        
end

function avg_pnt = getStimulPoint(time, grad)
    %1 sec tolerance
    tolerance = 1000;
    upper_time = time + tolerance;
    lower_time = time - tolerance;    

    %get index of upper and lower time
    upper_pnt = find(grad(:,1) > upper_time, 1);
    lower_pnt = find(grad(:,1) > lower_time, 1);
    
    %get the point with lowest gradient
    %get average points among X, Y, Rotation
    avg_pnt = 0;
    for type = 2:4        
        [val, pnt] = min(grad(lower_pnt:upper_pnt, type));
        avg_pnt = avg_pnt + pnt;
    end
    avg_pnt = round(avg_pnt/3) + lower_pnt;
end