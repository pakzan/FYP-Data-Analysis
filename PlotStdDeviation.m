%plot standard deviation of 6 positions of each type together
function PlotStdDeviation()
    %get directory info
    paths = {'Beetle 10 (48_27)/', 'Beetle 1 (48_24)/', 'Beetle 2 (41_23)/', 'Beetle 3 (45_25)/', 'Beetle 4 (44_23)/', 'Beetle 5 (36_25)/', 'Beetle 6 (52_24)/', 'Beetle 7 (49_25)/', 'Beetle 8 (44_22)/', 'Beetle 9 (47_25)/'};
    folder = {'right top/', 'right mid/', 'right bot/', 'left top/', 'left mid/', 'left bot/'};
    %declaration
    types = {'X', 'Y', 'Rot', 'Vx', 'Vy', 'Vrot', 'Ax', 'Ay', 'Arot'};
    ytext = {'(cm)', '(cm)', '(rad)', '(cm/s)', '(cm/s)', '(rad/s)', '(cm/s^2)', '(cm/s^2)', '(rad/s^2)'};
    
    for path_i = 1:length(paths)
        path = char(paths(path_i));
        %create folder if doesnt exists
        if ~exist(strcat(path, 'stdD'), 'dir')
            mkdir(strcat(path, 'stdD'));
        end

        %loop all files
        for pos = 1:length(folder)
            %get current file
            var(pos) = load(strcat(path, char(folder(pos)), 'stdDeviation.mat'));        
        end
        %plot data
        for type = 1:size(var(1).val_change, 2)
            type_data = zeros(size(var(1).val_change, 1), length(folder));
            %get data of same type from each position
            for pos = 1:length(folder)
                type_data(:,pos) = var(pos).val_change(:,type);
            end
            hold off;
            boxplot(type_data, folder);

            %add details
            ylabel(ytext(type));

            title(strcat('Standard Deviation of Beetle at: ',char(types(type))));
            %save graph
            saveas(gcf, strcat(path, 'stdD/', char(types(type)), '(stdD)', '.jpg'));
        end
    end
end
