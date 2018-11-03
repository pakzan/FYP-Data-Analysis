function PlotGraph()
    %get directory info
    path = 'Beetle 1/right_top/';
    dinfo = dir(strcat(path, '*.txt'));
    
    %loop all files
    for i = 1:length(dinfo)
        global var;
        %convert current loop index to string
        no_str = int2str(i);
        %get current file
        filename = dinfo(i).name;
        var = load(strcat(path, filename));
        
        %smooth data
        smoothData();
        
        plotDisp(var);
        %save graph
        saveas(gcf, strcat(path, 'Disp', no_str, '.jpg'));
        
        plotVel(var);
        %save graph
        saveas(gcf, strcat(path, 'Vel', no_str, '.jpg'));
        
        plotXY(var);        
        %save graph
        saveas(gcf, strcat(path, 'XY', no_str, '.jpg'));
    end
end

function smoothData()    
    global var;
    %smoothen x, y, rotation
    for i = 2:size(var,2)-1
        var(:,i) = smooth(var(:,1),var(:,i),0.3,'rloess');
    end
    %filter and smoothen piezo
    piezo = var(:,8);
    piezo(piezo < 0.2) = 0;
    %var(:,8) = smooth(var(:,1),piezo,0.1,'rloess');
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
    plot(var(:,1),var(:,4)/30);
    %plot piezo
    plot(var(:,1),var(:,8));

    %add details
    xlabel('Time(ms)');
    title('Displacement of Beetle when encountering an obstacle');
    legend('X (cm)','Y (cm)','Rot (x30 deg)','piezo (x1 V)','Location','BestOutside');
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
    %plot piezo
    plot(var(:,1),var(:,8));

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

function plotXY(var)
    %smoothen and plot x, y
    hold off;
    %overwrite timestamp value to use plotMaxMin function
    var(:,1) = smooth(var(:,3),var(:,2),0.4,'rloess');
    
    plot(var(:,1), var(:,3));
    hold on;
    %plot piezo
    plot(var(:,1), var(:,8));

    %add details
    xlabel('Horizontal Path(cm)');
    title('Movement of Beetle when encountering an obstacle');
    legend('Y (cm)','piezo (x1 V)','Location','BestOutside');
    %include max and min point of X, Y
    plotMaxMin(2, 'X', var);
    plotMaxMin(3, 'Y', var);
end
