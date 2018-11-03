%plot standard deviation of 6 positions of each type together
function PlotStdDeviation()
    %get directory info
    path = 'Beetle 1/';
    folder = {'right_top', 'right_mid', 'right_bot', 'left_top', 'left_mid', 'left_bot'};
    %declaration
    types = {'X', 'Y', 'Rot', 'Vx', 'Vy', 'Vrot'};
    
    %loop all files
    for i = 1:length(folder)
        %get current file
        var(i) = load(strcat(path, char(folder(i)), '/stdDeviation.mat'));        
    end
    %plot data
    for i = 1:size(var, 2)
        type_data = zeros(size(var(i).val_change, 1), size(var(i).val_change, 2));
        %get data of same type from each position
        for j = 1:size(var(i).val_change, 2)
            type_data(:,j) = var(j).val_change(:,i);
        end
        boxplot(type_data, folder);
        ylabel('(cm)');
        if i == 3 || i == 6
            ylabel('(rad)');
        end
        title(strcat('Standard Deviation of Beetle at: ',char(types(i))));
        %save graph
        saveas(gcf, strcat(path, 'stdD/', char(types(i)), '(stdD)', '.jpg'));
    end
end
