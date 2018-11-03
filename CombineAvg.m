function CombineAvg()
    %get directory info
    path = 'Beetle 1/';
    folder = {'right_top/', 'right_mid/', 'right_bot/', 'left_top/', 'left_mid/', 'left_bot/'};
    
    %declaration
    max_index = 1800;
    avg_piezo = zeros(max_index, 1); 
    all_var = zeros(max_index, 8, length(folder)); %(index, type, position)
    
    %get average data in all positions
    for pos = 1:length(folder)       
        dinfo = dir(strcat(path, char(folder(pos)), '*.txt'));
        var = zeros(max_index,8); 
        %get average data in each position
        for file = 1:length(dinfo)
            %get current file
            filename = dinfo(file).name;
            cur_var = load(strcat(path, char(folder(pos)), filename));  
            
            %prevent matrix index out of bound
            cur_var = cur_var(1:max_index, :);
            var = var + cur_var / length(dinfo);
        end
        
        %smooth data
        var = smoothData(var);
        all_var(:,:, pos) = var;
    end
    %get average piezo from all positions
    for pos = 1:size(all_var, 3) 
        avg_piezo = avg_piezo + all_var(:, 8, pos) / pos;
    end
    %input results of average piezo into last index of all_var
    all_var(:,8, 6) = avg_piezo;
    %filter piezo
    grad = getGradient(all_var(:,:,6));
    start_stim = getStimulPoint(5000, grad);
    end_stim = getStimulPoint(10000, grad);
    
    all_var(1:start_stim, 8, 6) = 0;
    all_var(end_stim:max_index, 8, 6) = 0;
    
    %plotAll(all_var);
    plotXY(all_var, start_stim, end_stim);
end

function var = smoothData(var)
    %smoothen x, y, rotation and piezo
    for i = 2:size(var,2)
        var(:,i) = smooth(var(:,1),var(:,i),0.3,'rloess');
    end
    
    %convert degree to radian
    var(:,4) = deg2rad(var(:,4));
    var(:,7) = deg2rad(var(:,7));
end

function plotAll(var)
    %declaration
    path = 'Beetle 1/cmbAvg/';
    types = {'X', 'Y', 'Rot', 'Vx', 'Vy', 'Vrot'};
    
    %plot average data of all types and positions
    %6 types
    for type = 1:6
        hold off;
        %plot data of same type from each position
        for pos = 1:size(var, 3)
            time = var(:,1, pos);
            plot(time, var(:,type+1, pos));
            hold on;
        end
        %plot and scale the piezo
        height = ylim;
        G_height = height(2) - height(1);
        plot(time, var(:,8, pos)*G_height/10);
        
        %add details
        ylabel('(cm)');
        if type == 3 || type == 6
            ylabel('(rad)');
        end
        xlabel('Time(ms)');
        title(strcat('Movement of Beetle at: ',char(types(type))));
        legend('right top', 'right mid', 'right bot', 'left top', 'left mid', 'left bot', 'piezo', 'Location','BestOutside');
        %save graph
        saveas(gcf, strcat(path, char(types(type)), '(cmbAvg)', '.jpg'));
    end
end

function plotXY(var, start_stim, end_stim)
    %declaration
    path = 'Beetle 1/cmbAvg/';
    
    %smoothen and plot x, y
    hold off;    
    %plot data of XY from each position
    for pos = 1:size(var, 3)        
        graph(pos) = plot(smooth(var(:,3, pos),var(:,2, pos),0.4,'rloess'), var(:,3, pos));
        hold on;    
        %plot piezo stimulation points
        temp_var = var(start_stim:end_stim,:, pos);
        graph(7) = plot(smooth(temp_var(:,3,:),temp_var(:,2,:),0.4,'rloess'), temp_var(:,3,:),'k');
    end

    %add details
    xlabel('Horizontal (cm)');
    ylabel('Vertical (cm)');
    title('Movement of Beetle at: XY');
    legend([graph(1), graph(2), graph(3), graph(4), graph(5), graph(6), graph(7)], ...
    {'right top', 'right mid', 'right bot', 'left top', 'left mid', 'left bot', 'piezo'}, ...
    'Location','BestOutside');
    %save graph
    saveas(gcf, strcat(path, 'XY(cmbAvg)', '.jpg'));
end

function pnt = getStimulPoint(time, grad)
    %1 sec tolerance
    tolerance = 1000;
    upper_time = time + tolerance;
    lower_time = time - tolerance;    

    %get index of upper and lower time
    upper_pnt = find(grad(:,1) > upper_time, 1);
    lower_pnt = find(grad(:,1) > lower_time, 1);
    
    %get the point at piezo with highest gradient
    type = 8; 
    [val, pnt] = max(grad(lower_pnt:upper_pnt, type));
    pnt = pnt + lower_pnt;
end

function grad = getGradient(var)
    %gradient has 1 less index
    grad = var(1:size(var,1)-1, :);
    %get gradient of piezo
    grad(:,8) = diff(var(:,8))./diff(var(:,1));
end
