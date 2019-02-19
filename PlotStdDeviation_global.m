%plot standard deviation of 6 positions of each type together
function PlotStdDeviation_global()
    %get directory info
    paths = {'Beetle 6 (52_24)/', 'Beetle 7 (49_25)/', 'Beetle 10 (48_27)/', 'Beetle 1 (48_24)/', 'Beetle 9 (47_25)/', 'Beetle 3 (45_25)/', 'Beetle 4 (44_23)/', 'Beetle 8 (44_22)/', 'Beetle 2 (41_23)/', 'Beetle 5 (36_25)/'};
    paths_title = {'6(52)', '7(49)', '10(48)', '1(48)', '9(47)', '3(45)', '4(44)', '8(44)', '2(41)', '5(36)'};
    folders = {'right top/', 'right mid/', 'right bot/', 'left top/', 'left mid/', 'left bot/'};
    %declaration
    types = {'X', 'Y', 'Rot', 'Vx', 'Vy', 'Vrot', 'Ax', 'Ay', 'Arot'};
    ytext = {'(cm)', '(cm)', '(rad)', '(cm/s)', '(cm/s)', '(rad/s)', '(cm/s^2)', '(cm/s^2)', '(rad/s^2)'};
    
    combine_fol = 'Beetle all/';
    for folder_i = 1:length(folders)
        folder = char(folders(folder_i));
        
        %create folder if doesnt exists
        if ~exist(strcat(combine_fol, 'stdD'), 'dir')
            mkdir(strcat(combine_fol, 'stdD'));
        end
        if ~exist(strcat(combine_fol, 'stdD/', folder), 'dir')
            mkdir(strcat(combine_fol, 'stdD/', folder));
        end

        %loop all files
        for pos = 1:length(paths)
            %get current file
            var(pos) = load(strcat(char(paths(pos)), folder, 'stdDeviation.mat')); %(beetle, sample, type)
        end
        %plot data
        for type = 1:size(var(1).val_change, 2)
            type_data = zeros(size(var(1).val_change, 1), length(paths));
            %get data of same type from each position
            for pos = 1:length(paths)
                type_data(:,pos) = var(pos).val_change(:,type);
            end
            hold off;    
            boxplot(type_data, paths_title);

            %add details
            xlabel('(gram)');
            ylabel(ytext(type));

            title(strcat('Standard Deviation of Beetle at: ', folder, char(types(type))));
            %save graph
            saveas(gcf, strcat(combine_fol, 'stdD/', folder, char(types(type)), '(stdD)', '.jpg'));
        end
    end
end
