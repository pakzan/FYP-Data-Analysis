function Sensor()
    delete(instrfindall);
    s = serial('COM4');
    set(s, 'DataBits', 8);
    set(s, 'StopBits', 1);
    set(s, 'BaudRate', 57600);
    set(s, 'Parity', 'none');
    fopen(s);
    
    tic;
    global fid;
    fid = fopen(strcat(datestr(now,'ddmmyy_HHMMSS'), '.txt'),'wt');
    hold off;

    %call onCleanup when "Ctrl C" detected
    cleanupObj = onCleanup(@cleanMeUp);

    %remove previous data
    fgetl(s);fgetl(s);
    
    moved = false;
    while(toc < 15)
        % call python to move linear actuator after 5 sec
        if(toc > 5 && ~moved)
            edit startMove.txt;
            moved = true;
        end
        
        %remove empty line
        out = fgetl(s);
        while(isempty(out))
            out = fgetl(s);
        end

        Num = strsplit(out);
        %print to file
        fprintf(fid, '%s\t\t', Num{:});
        fprintf(fid, '\n');
        %print to console
        fprintf('%s\t\t', Num{:});
        fprintf('\n');
    end
end

% fires when main function terminates
function cleanMeUp()
    %close file and program properly
    global fid;
    fclose(fid);
    close; 
end
