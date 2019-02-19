function var = smoothPiezo(var)
    piezo_pos = size(var, 2);
    %filter piezo
    piezo = zeros(size(var,1), 1);
    %get stimulation points
    stimul_pnt = getStimulPoints(var);
    %get mean value within stimulation points
    temp_piezo = var(:,piezo_pos);
    piezo_mean = mean(temp_piezo(stimul_pnt,1));
    %remove noise and set mean value
    piezo(:, 1) = 0;
    piezo(stimul_pnt(1):stimul_pnt(end), 1) = piezo_mean;
    
    var(:,piezo_pos) = piezo;
end