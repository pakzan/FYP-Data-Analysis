function var = smoothData(var)
    %smoothen x, y, rotation and piezo
    for i = 2:size(var,2)-1
        var(:,i) = smooth(var(:,1),var(:,i),0.3,'rloess');
    end
    
    %convert degree to radian
    var(:,4) = deg2rad(var(:,4));
    var(:,7) = deg2rad(var(:,7));
end