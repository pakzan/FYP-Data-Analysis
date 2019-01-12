function Sensor()
    delete(instrfindall);
    s = serial('COM4');
    set(s, 'DataBits', 8);
    set(s, 'StopBits', 1);
    set(s, 'BaudRate', 57600);
    set(s, 'Parity', 'none');
    fopen(s);
    
    global fid;
    timestamp = datestr(now,'ddmmyy_HHMMSS');
    fid = fopen(strcat(timestamp, '.txt'),'wt');
    hold off;
    
    %call onCleanup when "Ctrl C" detected
    cleanupObj = onCleanup(@cleanMeUp);

    %remove previous data
    fgetl(s);fgetl(s);

	% call python to start record
    fpip = fopen(strcat('startRecord', timestamp, '.txt'),'wt');
    fclose(fpip);
    
    tic;
    while(toc < 15)        
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
