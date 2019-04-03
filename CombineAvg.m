function CombineAvg()
    %get directory info
    global path
    paths = {'Beetle 3 (45_25)/', 'Beetle 4 (44_23)/', 'Beetle 5 (36_25)/', 'Beetle 6 (52_24)/', 'Beetle 7 (49_25)/', 'Beetle 8 (44_22)/', 'Beetle 9 (47_25)/'};
    folder = {'right top/', 'right mid/', 'right bot/', 'left top/', 'left mid/', 'left bot/'};

    for path_i = 1:length(paths)
        path = char(paths(path_i));
        fprintf('\nOpenning path %s\n', path);
        
        %create folder if doesnt exists
        if ~exist(strcat(path, 'cmbAvg'), 'dir')
            mkdir(strcat(path, 'cmbAvg'));
        end
        %declaration
        piezo_pos = 11;
        max_index = 1800;
        avg_piezo = zeros(max_index, 1); 
        all_var = zeros(max_index, piezo_pos, length(folder)); %(index, type, position)
    
        %get average data in all positions
        for pos = 1:length(folder)
            fprintf('Openning folder %s\n', char(folder(pos)));
            dinfo = dir(strcat(path, char(folder(pos)), '*.txt'));
            var = zeros(max_index,8); 
            %get average data in each position
            file_num = 0;
            for file = 1:length(dinfo)
                %get current file
                filename = dinfo(file).name;
                fprintf('Openning file %s\n', filename);
                cur_var = load(strcat(path, char(folder(pos)), filename));  

                %prevent matrix index out of bound
                % check if the file is long enough
                if max_index > size(cur_var, 1)
                    continue
                end
                cur_var = cur_var(1:max_index, :);
                var = var + cur_var;
                file_num = file_num + 1;
            end
            var = var / length(dinfo);

            %smooth data
            var = smoothData(var);
            all_var(:,1:7, pos) = var(:,1:7);
            all_var(:,piezo_pos, pos) = var(:,8);
        end

        %calculate acceleration
        for pos = 1:length(folder)
            all_var(:,8:10, pos) = getSmoothGrad(all_var(:,1, pos), all_var(:,5:7, pos));
        end

        %get average piezo from all positions
        for pos = 1:size(all_var, 3) 
            avg_piezo = avg_piezo + all_var(:, piezo_pos, pos) / pos;
        end
        %input results of average piezo into last index of all_var
        all_var(:,piezo_pos, 6) = avg_piezo;
        %smooth piezo data and store the value to last postion
        all_var(:,:, 6) = smoothPiezo(all_var(:,:, 6));
        %get stimulation points
        stimul_pnts = getStimulPoints(all_var(:,:, 6));
        start_pnt = stimul_pnts(1);
        end_pnt = stimul_pnts(end);

        plotAll(all_var);
        plotXY(all_var, start_pnt, end_pnt);
    end
end

function plotAll(var)
    %declaration
    global path
    piezo_pos = size(var, 2);
    save_path = strcat(path, 'cmbAvg/');
    types = {'X', 'Y', 'Rot', 'Vx', 'Vy', 'Vrot', 'Ax', 'Ay', 'Arot'};
    ytext = {'(cm)', '(cm)', '(rad)', '(cm/s)', '(cm/s)', '(rad/s)', '(cm/s^2)', '(cm/s^2)', '(rad/s^2)'};
    
    %plot average data of all types and positions
    %6 types
    for type = 1:size(types, 2)
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
        plot(time, var(:,piezo_pos, pos)*G_height);
        
        %add details
        ylabel(ytext(type));
        
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
    save_path = strcat(path, 'cmbAvg/');
    
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
