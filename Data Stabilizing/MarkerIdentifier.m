mesoP = [16.0936,21.6356,184.151];         % INPUT PREDETERMINED MESOTHORAX COORDINATES HERE!
elytraL = 22.3;                           % INPUT PREDETERMINED ELYTRA - MESOTHORAX LENGTH HERE!
RW1L = 29.13552;                               % INPUT PREDETERMINED RIGHT WING 1 - MESOTHORAX LENGTH HERE!
LW1L = 31.66394;                               % INPUT PREDETERMINED LEFT WING 1 - MESOTHORAX LENGTH HERE!
RL1L = 23.80422;                               % INPUT PREDETERMINED RIGHT LEG - MESOTHORAX LENGTH HERE!
LL1L = 22.27274;                               % INPUT PREDETERMINED LEFT LEG - MESOTHORAX LENGTH HERE!

% Determining the Mesothorax

row = 1;

    filename = 'Trial 9.csv';
    offset = [5, 2];
    test = csvread(filename, offset(1), offset(2));
while row <= size(test,1)                
    diff = abs(test(row,[1 4 7 10 13 16 19 22]) - mesoP(1,1));       
    sorted = sort(diff);
    mindiff = sorted(1,1);
    mindiffE = sorted(1,2);
   
    mesoxcell = 3*(find(diff == mindiff)-1)+1;        % choose x cell closest to XmesoP
    mesoycell = 3*(find(diff == mindiff)-1)+2;
    mesozcell = 3*(find(diff == mindiff)-1)+3;
         
    Excell = 3*(find(diff == mindiffE)-1)+1;
    Eycell = 3*(find(diff == mindiffE)-1)+2;
    Ezcell = 3*(find(diff == mindiffE)-1)+3;
    
        
    if (abs(test(row, mesoycell) - mesoP(1,2))) > 8
                              
        mindiff = sorted(1,2);                            % To differentiate between mesothorax & elytra
        mindiffE = sorted(1,1);
        mesoxcell = 3*(find(diff == mindiff)-1)+1;        % choose x cell closest to XmesoP
        mesoycell = 3*(find(diff == mindiff)-1)+2;
        mesozcell = 3*(find(diff == mindiff)-1)+3;
        
        Excell = 3*(find(diff == mindiffE)-1)+1;
        Eycell = 3*(find(diff == mindiffE)-1)+2;
        Ezcell = 3*(find(diff == mindiffE)-1)+3;
        
                
    end
    
    emptymeso = isempty(mesoxcell);
    emptyelytra = isempty(Excell);
    
    if emptymeso == 1
        
    mesoxcell = Excell;        % choose x cell closest to XmesoP
    mesoycell = Eycell;
    mesozcell = Ezcell;
    
    else
        
        L(row, 1:3) = test(row, mesoxcell:mesozcell);
        LF(row, 1:3) = L(row, 1:3);
        R(row, 1:3) = test(row, mesoxcell:mesozcell);
        RF(row, 1:3) = R(row, 1:3);
            
    end
    
    
    if emptyelytra == 1
        
        Excell = mesoxcell;
        Eycell = mesoycell;
        Ezcell = mesozcell;
    
    end
        
        
    L(row, 4:6) = test(row, Excell:Ezcell);
    LF(row, 4:6) = L(row, 4:6);
    R(row, 4:6) = test(row, Excell:Ezcell);
    RF(row, 4:6) = R(row, 4:6);
    
    if (abs(test(row, Excell) - test(row, mesoxcell))) > 3
        
    L(row, 4:6) = 0;                                          % In case elytra is not detected.
    R(row, 4:6) = 0;
    LF(row, 4:6) = L(row, 4:6);
    RF(row, 4:6) = R(row, 4:6);
    
    end
    
    % Issue with if there are 2 x values that give the same diff. Use 190115 % capture 4 for testing.
    
    % Separating into L & R
    % Left ==> x < xmeso
    
    column = 1;
    while column <= 22

        if test(row, column) < test(row, mesoxcell)

            if test(row, column) ~= test(row, Excell)

                L(row, column+6:column+8) = test(row, column:column+2);

            end
            
        end
        
        if test(row, column) > test(row, mesoxcell)

            if test(row, column) ~= test(row, Excell)

                R(row, column+6:column+8) = test(row, column:column+2);

            end
            
        end
             
        column = column+3;
        
    end
            
    row = row + 1;
    
end

lrow = 1;
lcolumn = 7;

while lrow <= size(L,1)
    
    while lcolumn <=28
        
        if L(lrow,lcolumn)~=0
            
         ldiff = abs(L(lrow,lcolumn) - L(lrow,1));
         lsort(1,lcolumn) = ldiff;
         
        elseif L(lrow,lcolumn)==0
            
            lsort(1,lcolumn) = 0;
         
        end
        
        lcolumn = lcolumn + 3;
        
    end
        
         lsorted = sort(lsort);
         lmindiff = lsorted(1,[end-2]);
         lmindiff2 = lsorted(1,[end-1]);
         lmindiff3 = lsorted(1,[end]);
         
         lcolumn = 7;
         
         while lcolumn <=28
             
             if abs(L(lrow,lcolumn)- L(lrow,1)) == lmindiff
                 
                 LF(lrow, 7:9) = L(lrow, lcolumn:lcolumn+2);
                 
             elseif abs(L(lrow,lcolumn)- L(lrow,1)) == lmindiff2
                 
                 LF(lrow, 10:12) = L(lrow, lcolumn:lcolumn+2);
                 
             elseif abs(L(lrow,lcolumn)- L(lrow,1)) == lmindiff3
                 
                 LF(lrow, 13:15) = L(lrow, lcolumn:lcolumn+2);
                 
             end
             
             lcolumn = lcolumn + 3;
             
         end
           
    lrow = lrow + 1;
    lcolumn = 7;
    lsz = size(lsort);
    lsort = zeros(lsz);
    
end

rrow = 1;
rcolumn = 7;

while rrow <= size(R,1)
    
    while rcolumn <=28
        
        if R(rrow,rcolumn)~=0
            
         rdiff = abs(R(rrow,rcolumn) - R(rrow,1));
         rsort(1,rcolumn) = rdiff;
         
        elseif R(rrow,rcolumn)==0
            
            rsort(1,rcolumn) = 0;
         
        end
        
        rcolumn = rcolumn + 3;
        
    end
        
         rsorted = sort(rsort);
         rmindiff = rsorted(1,[end-2]);
         rmindiff2 = rsorted(1,[end-1]);
         rmindiff3 = rsorted(1,[end]);
         
         rcolumn = 7;
         
         while rcolumn <=28
             
             if abs(R(rrow,rcolumn)- R(rrow,1)) == rmindiff
                 
                 RF(rrow, 7:9) = R(rrow, rcolumn:rcolumn+2);
                 
             elseif abs(R(rrow,rcolumn)- R(rrow,1)) == rmindiff2
                 
                 RF(rrow, 10:12) = R(rrow, rcolumn:rcolumn+2);
                 
             elseif abs(R(rrow,rcolumn)- R(rrow,1)) == rmindiff3
                 
                 RF(rrow, 13:15) = R(rrow, rcolumn:rcolumn+2);
                 
             end
             
             rcolumn = rcolumn + 3;
             
         end
           
    rrow = rrow + 1;
    rcolumn = 7;
    rsort = 0;
    rsz = size(rsort);
    rsort = zeros(rsz);
    
    
end

plot3(LF(:,1),L(:,2),L(:,3))
hold on
plot3(LF(:,4),L(:,5),L(:,6))
hold on
plot3(LF(:,7),L(:,8),L(:,9))
hold on
plot3(LF(:,13),LF(:,14),LF(:,15))
hold on
plot3(RF(:,7),RF(:,8),RF(:,9))
hold on
plot3(RF(:,13),RF(:,14),RF(:,15))

grid on


