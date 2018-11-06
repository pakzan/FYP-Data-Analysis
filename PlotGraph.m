function PlotGraph()
    %get directory info
    path = 'Beetle 2/';
    folder = {'right_top/', 'right_mid/', 'right_bot/', 'left_top/', 'left_mid/', 'left_bot/'};

    global var;
    %loop all folders
    for pos = 1:length(folder)
        dinfo = dir(strcat(path, char(folder(pos)), '*.txt'));
        %loop all files
        for i = 1:length(dinfo)
            fprintf('Openning file %s\n', dinfo(i).name);
            %convert current loop index to string
            no_str = int2str(i);
            %get current file
            filename = dinfo(i).name;
            var = load(strcat(path, char(folder(pos)), filename));  

            %smooth data
            smoothData();

            plotDisp(var);
            %save graph
            saveas(gcf, strcat(path, char(folder(pos)), 'Disp', no_str, '.jpg'));

            plotVel(var);
            %save graph
            saveas(gcf, strcat(path, char(folder(pos)), 'Vel', no_str, '.jpg'));

            %get stimulation points
            stimul_pnts = getStimulPoints(var);
            start_pnt = stimul_pnts(1);
            end_pnt = stimul_pnts(end);

            plotXY(var, start_pnt, end_pnt);        
            %save graph
            saveas(gcf, strcat(path, char(folder(pos)), 'XY', no_str, '.jpg'));
        end
        fprintf('Successfully saved %s\n\n', char(folder(pos)));
    end
end

function smoothData()    
    global var;
    %smoothen x, y, rotation
    for i = 2:size(var,2)-1
        var(:,i) = smooth(var(:,1),var(:,i),0.3,'rloess');
    end
    
    %convert degree to radian    
    var(:,4) = deg2rad(var(:,4));
    var(:,7) = deg2rad(var(:,7));
    
    %filter piezo
    piezo = zeros(size(var,1), 1);
    %get stimulation points
    stimul_pnt = getStimulPoints(var);
    %get mean value within stimulation points
    temp_piezo = var(:,8);
    piezo_mean = mean(temp_piezo(stimul_pnt,1));
    %set mean value
    piezo(stimul_pnt(1):stimul_pnt(end), 1) = piezo_mean;
    
    var(:,8) = piezo;
end

function pnt = getStimulPoint(var, time, tolerance)
    piezo = var(:,8);
    
    %get stimul pnt within tolerance
    start_tol = find(var(:,1) > time - tolerance, 1);
    end_tol = find(var(:,1) > time + tolerance, 1);
    pnts = find(piezo(start_tol:end_tol,1)>0.2);
    
    %if stimul_pnt has no value, set default pnt
    if (size(pnts, 1) == 0)
        pnts = find(var(:,1) > time, 1);        
        pnt = pnts(1,1);
    else
        pnt = start_tol + pnts(1,1);
    end
end

function pnts = getStimulPoints(var)
    %1 sec tolerance
    tolerance = 1000;
    %stimulation from 5 sec to 10 sec
    start_time = 5000;
    end_time = 10000;
    
    %index of respective time
    start_pnt = getStimulPoint(var, start_time, tolerance);
    end_pnt = getStimulPoint(var, end_time, tolerance);
    
    pnts = start_pnt : end_pnt;
end

function plotMaxMin(i, type, var)
    %plot max point
    [y,x] = max(var(:,i));
    %get timestamp at max point
    x = var(x,1);
    text(x, y, strcat(type, 'max: ', sprintf('%.2f',y))); 
    
    %plot min point
    [y,x] = min(var(:,i));
    %get timestamp at max point
    x = var(x,1);
    text(x, y, strcat(type, 'min: ', sprintf('%.2f',y)));
end

function plotDisp(var)
    %plot x, y, rotation
    hold off;
    plot(var(:,1),var(:,2));
    hold on;
    plot(var(:,1),var(:,3));
    plot(var(:,1),var(:,4));
    
    %plot and scale the piezo
    height = ylim;
    G_height = height(2) - height(1);
    plot(var(:,1), var(:,8)*G_height*2);

    %add details
    xlabel('Time(ms)');
    title('Displacement of Beetle when encountering an obstacle');
    legend('X (cm)','Y (cm)','Rot (rad)','piezo','Location','BestOutside');
    %include max and min point of X, Y, Rot
    plotMaxMin(2, 'X', var);
    plotMaxMin(3, 'Y', var);
    var(:,4) = var(:,4)/30;
    plotMaxMin(4, 'R', var);
end

function plotVel(var)
    %plot x, y, rotation
    hold off;
    plot(var(:,1),var(:,5));
    hold on;
    plot(var(:,1),var(:,6));
    plot(var(:,1),var(:,7)/30);
    %plot and scale the piezo
    height = ylim;
    G_height = height(2) - height(1);
    plot(var(:,1), var(:,8)*G_height*2);

    %add details
    xlabel('Time(ms)');
    title('Velocity of Beetle when encountering an obstacle');
    legend('Vx (cm/s)','Vy (cm/s)','Vrot (x30 deg/s)','piezo (x1 V)','Location','BestOutside');
    %include max and min point of X, Y, Rot
    plotMaxMin(5, 'X', var);
    plotMaxMin(6, 'Y', var);
    var(:,7) = var(:,7)/30;
    plotMaxMin(7, 'R', var);
end

function plotXY(var, start_stim, end_stim)
    %smoothen and plot x, y
    hold off;
    %overwrite timestamp value to use plotMaxMin function
    var(:,1) = smooth(var(:,3),var(:,2),0.4,'rloess');
    plot(var(:,1), var(:,3));
    hold on;
    
    %plot piezo stimulation points
    temp_var = var(start_stim:end_stim,:);
    plot(temp_var(:,1), temp_var(:,3),'k','LineWidth',2);

    %add details
    xlabel('Horizontal Path(cm)');
    ylabel('Vertical (cm)');
    title('Movement of Beetle when encountering an obstacle');
    legend('Movement path', 'piezo','Location','BestOutside');
    %include max and min point of X, Y
    plotMaxMin(2, 'X', var);
    plotMaxMin(3, 'Y', var);
end
