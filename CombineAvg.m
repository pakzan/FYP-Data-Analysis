function CombineAvg()
    %get directory info
    global path
    path = 'Beetle 2/';
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
    
    %smooth piezo data and store the value to last postion
    all_var(:,:, 6) = smoothPiezo(all_var(:,:, 6));
    %get stimulation points
    stimul_pnts = getStimulPoints(all_var(:,:, 6));
    start_pnt = stimul_pnts(1);
    end_pnt = stimul_pnts(end);
        
    all_var(1:start_pnt, 8, 6) = 0;
    all_var(end_pnt:max_index, 8, 6) = 0;
    
    %plotAll(all_var);
    plotXY(all_var, start_pnt, end_pnt);
end

function var = smoothData(var)
    %smoothen x, y, rotation and piezo
    for i = 2:size(var,2)-1
        var(:,i) = smooth(var(:,1),var(:,i),0.3,'rloess');
    end
    
    %convert degree to radian
    var(:,4) = deg2rad(var(:,4));
    var(:,7) = deg2rad(var(:,7));
end

function var = smoothPiezo(var)
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

function plotAll(var)
    %declaration
    global path
    save_path = strcat(path, '/cmbAvg/');
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
        plot(time, var(:,8, pos)*G_height);
        
        %add details
        ylabel('(cm)');
        if type == 3 || type == 6
            ylabel('(rad)');
        end
        xlabel('Time(ms)');
        title(strcat('Movement of Beetle at: ',char(types(type))));
        legend('right top', 'right mid', 'right bot', 'left top', 'left mid', 'left bot', 'piezo', 'Location','BestOutside');
        %save graph
        saveas(gcf, strcat(save_path, char(types(type)), '(cmbAvg)', '.jpg'));
    end
end

function plotXY(var, start_stim, end_stim)
    %declaration
    global path
    save_path = strcat(path, '/cmbAvg/');
    
    %smoothen and plot x, y
    hold off;    
    %plot data of XY from each position
    for pos = 1:size(var, 3)
        var(:,1, pos) = smooth(var(:,3, pos),var(:,2, pos),0.4,'rloess');
        graph(pos) = plot(var(:,1, pos), var(:,3, pos));
        hold on;
        %plot piezo stimulation points
        temp_var = var(start_stim:end_stim,:, pos);
        graph(7) = plot(temp_var(:,1,:), temp_var(:,3,:),'k','LineWidth',2);
    end

    %add details
    xlabel('Horizontal (cm)');
    ylabel('Vertical (cm)');
    title('Movement of Beetle at: XY');
    legend([graph(1), graph(2), graph(3), graph(4), graph(5), graph(6), graph(7)], ...
    {'right top', 'right mid', 'right bot', 'left top', 'left mid', 'left bot', 'piezo'}, ...
    'Location','BestOutside');
    %save graph
    saveas(gcf, strcat(save_path, 'XY(cmbAvg)', '.jpg'));
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
