function PlotGraph()
    %get directory info
    path = 'Beetle 1 (48_24)/';
    folder = {'right top/', 'right mid/', 'right bot/', 'left top/', 'left mid/', 'left bot/'};

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
            var = smoothData(var);
            var = smoothPiezo(var);

            plotDisp(var);
            %save graph
            saveas(gcf, strcat(path, char(folder(pos)), 'Disp', no_str, '.jpg'));

            plotVel(var);
            %save graph
            saveas(gcf, strcat(path, char(folder(pos)), 'Vel', no_str, '.jpg'));

            plotAcc(var);
            %save graph
            saveas(gcf, strcat(path, char(folder(pos)), 'Acc', no_str, '.jpg'));

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
    plotMaxMin(4, 'R', var);
end

function plotVel(var)
    %plot x, y, rotation
    hold off;
    plot(var(:,1),var(:,5));
    hold on;
    plot(var(:,1),var(:,6));
    plot(var(:,1),var(:,7));
    %plot and scale the piezo
    height = ylim;
    G_height = height(2) - height(1);
    plot(var(:,1), var(:,8)*G_height*2);

    %add details
    xlabel('Time(ms)');
    title('Velocity of Beetle when encountering an obstacle');
    legend('Vx (cm/s)','Vy (cm/s)','Vrot (rad/s)','piezo','Location','BestOutside');
    %include max and min point of X, Y, Rot
    plotMaxMin(5, 'X', var);
    plotMaxMin(6, 'Y', var);
    plotMaxMin(7, 'R', var);
end

function plotAcc(var)
    %calculate acceleration from velocity
    acc(:,1) = var(:,1);
    acc(:,2:4) = getSmoothGrad(var(:,1), var(:,5:7));
    
    %plot x, y, rotation    
    hold off;
    plot(var(:,1),acc(:,2));
    hold on;
    plot(var(:,1),acc(:,3));
    plot(var(:,1),acc(:,4));
    %plot and scale the piezo
    height = ylim;
    G_height = height(2) - height(1);
    plot(var(:,1), var(:,8)*G_height*2);

    %add details
    xlabel('Time(ms)');
    title('Acceleration of Beetle when encountering an obstacle');
    legend('Ax (cm/s^2)','Ay (cm/s^2)','Arot (rad/s^2)','piezo','Location','BestOutside');
    %include max and min point of X, Y, Rot
    plotMaxMin(2, 'X', acc);
    plotMaxMin(3, 'Y', acc);
    plotMaxMin(4, 'R', acc);
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
