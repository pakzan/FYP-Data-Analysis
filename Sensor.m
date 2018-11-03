function varargout = Manual(varargin)
    % MANUAL MATLAB code for Manual.fig
    %      MANUAL, by itself, creates a new MANUAL or raises the existing
    %      singleton*.
    %
    %      H = MANUAL returns the handle to a new MANUAL or the handle to
    %      the existing singleton*.
    %
    %      MANUAL('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in MANUAL.M with the given input arguments.
    %
    %      MANUAL('Property','Value',...) creates a new MANUAL or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before Manual_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to Manual_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help Manual

    % Last Modified by GUIDE v2.5 11-Mar-2018 17:51:32

    delete(instrfindall);
    s = serial('COM4');
    set(s, 'DataBits', 8);
    set(s, 'StopBits', 1);
    set(s, 'BaudRate', 57600);
    set(s, 'Parity', 'none');
    fopen(s);
    global fid;
    fid = fopen(strcat(datestr(now,'ddmmyy_HHMMSS'), '.txt'),'wt');
    hold off;

    %call onCleanup when "Ctrl C" detected
    cleanupObj = onCleanup(@cleanMeUp);

    %remove previous data
    fgetl(s);fgetl(s);
    
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
        %calculate position
    %     if(length(Num) == 7)
    %         x1= Num{:,2};
    %         x2= Num{:,3};
    %         x3= Num{:,4};
    %         x4= Num{:,5};
    %         fprintf('%s\t\t', Num{:,1});
    %     end
    end
end

% fires when main function terminates
function cleanMeUp()
    %close file and program properly
    global fid;
    fclose(fid);
    close; 
end
