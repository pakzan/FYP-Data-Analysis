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
    piezo_pos = size(var, 2);
    piezo = var(:,piezo_pos);
    
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