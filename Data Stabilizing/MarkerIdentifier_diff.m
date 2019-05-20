function MarkerIdentifier_diff()
    global col_length
    global row_length
    global dimens
    global parts
    global tolerance
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% load mat from raw csv %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ignore first 5 rows and first 2 columns
    filename = 'Trial 5.csv';
    offset = [5, 2];
    var = csvread(filename, offset(1), offset(2));
    
%     var = importdata('test.csv');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get/set general variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [col_length, row_length] = size(var);
    dimens = 3;
    parts = row_length / dimens;
    
    % set tolerance to obtain clean result
    % tolerance = [refining row, record prev_row, include to sample]
    tolerance = [5, 20, 20];
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% main function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    var = organiseArr(var);
    classify_var = nan(1, dimens+1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot graph %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off
    
    for part = 0:parts-1
        xyz = [part*3 + 1, part*3 + 2, part*3 + 3];

        % ignore nan variables
        idxs = ~isnan(var(:, xyz(1)));
        idys = ~isnan(var(:, xyz(2)));
        idzs = ~isnan(var(:, xyz(3)));

        plot3(var(idxs, xyz(1)), var(idys, xyz(2)), var(idzs, xyz(3)));
        hold on
        
        classify_var = [classify_var; var(idxs, xyz(1):xyz(3)), part*idxs(idxs, 1)];
    end
    grid on
    
    save('classify_var.mat', 'classify_var');
end


function org_var = organiseArr(var)
    global col_length
    global row_length
    
    % convert 1d array to 2d array (x, y, z)
    prev_row_2d = reshape_1to2(var(col_length, :));
    
    % sort and store value to new_var
    org_var = nan(col_length, row_length);
    
    % sort and store value to partition (min, max)
%     partition(:,:,1) = prev_row_2d;
%     partition(:,:,2) = prev_row_2d;
    
    
partition(:,:,1) = [38.5644   11.9581  161.3160;
   18.1454    0.4354  169.1940;
  -11.7752   13.2488  168.4430;
   26.2134   26.0135  144.1060;
   -4.9053   23.9137  145.3270;
   17.8463   21.7166  182.1380;
  -38.0523   -6.3313  141.4340;
   45.4292  -10.8594  136.7680];


partition(:,:,2) = [48.6909   34.8307  190.8390;
   21.7721    4.0456  183.4610;
   -5.6663   40.1003  191.9900;
   44.9496   42.1272  184.9380;
   10.6053   45.1484  185.2890;
   19.5270   24.4837  187.2220;
  -12.0391   62.3836  212.3480;
   74.2961   50.1062  203.8060];
   
    for row_ind = 1:col_length
        row_2d = reshape_1to2(var(row_ind, :));
        [prev_row_2d, row_2d, partition] = organiseRow(row_ind, partition, prev_row_2d, row_2d);
        org_var(row_ind, :) = reshape_2to1(row_2d);
    end
    
    
        hold on
    for row_ind = 1:8
        plot3(partition(row_ind,1,1), partition(row_ind,2,1), partition(row_ind,3,1),'-s','MarkerSize',10,'MarkerEdgeColor','b');
        hold on
        plot3(partition(row_ind,1,2), partition(row_ind,2,2), partition(row_ind,3,2),'-s','MarkerSize',10,'MarkerEdgeColor','b');
        hold on
    end
end

function [prev_row, org_row, partition] = organiseRow(abs_row, partition, prev_row, row)
    global dimens
    global parts
    global tolerance
    
    center = [45.2774   21.5090  177.0941;
    20.0274    1.7469  177.2506;
    -6.5232   30.7564  181.0590;
    36.3982   34.5662  166.8682;    
    7.5900   29.2540  146.9629;
    18.6987   23.1396  185.3144;
    -25.7260   30.1086  174.8343;
    60.3430   20.4196  165.8223];
hole1 = [-6, 38, 178];
hole2 = [-6, 37, 170];

    % calculate the (x, y, z) distance for all parts    
    % between prev_row and row
    dist = zeros(parts, parts);
    for part = 1:parts
        for temp_part = 1:parts
        	dist(part, temp_part) = norm(row(temp_part, :) - prev_row(part, :));
        end
    end
    
    % reorganise the parts
    temp_dist = nan(parts, parts);
    temp_partition = partition;
    org_row = nan(parts, dimens);
    while any(~isnan(dist(:)))
        % find the minimum (x, y, z) distance for all parts 
        [minval, ind] = min(dist(:));
        [ind_row, ind_col] = ind2sub(size(dist), ind);
        
        % put candidate on hold
        if sum(abs(minval-dist(ind_row, :)) < tolerance(1)) > 1
            temp_dist(ind_row, :) = dist(ind_row, :);
            dist(ind_row, :) = nan;
            continue
        end
        
        org_row(ind_row, :) = row(ind_col, :);
        
        % replace used column and row to nan
        dist(ind_row, :) = nan;
        dist(:, ind_col) = nan;
        
        temp_partition(ind_row, :, :) = nan;
        temp_dist(:, ind_col) = nan;
    end
    
%     if any(~isnan(temp_dist(:)))
%         [org_pos, ~] = combSum(temp_dist, 1, nan(1, parts));
%         
%         for part = 1:parts
%             if ~isnan(org_pos(part))
%                 org_row(org_pos(part), :) = row(part, :);
%             end
%         end
%     end    
    
%     while any(~isnan(temp_dist(:)))
%         % find the minimum (x, y, z) distance for all parts 
%         [~, ind] = max(temp_dist(:));
%         [ind_row, ind_col] = ind2sub(size(temp_dist), ind);
%         
%         [~, ind_row] = min(temp_dist(:, ind_col));
%         
%         org_row(ind_row, :) = row(ind_col, :);
%         
%         % replace used column and row to nan
%         temp_dist(ind_row, :) = nan;
%         temp_dist(:, ind_col) = nan;
%     end
    
    while any(~isnan(temp_dist(:)))
        % find the minimum (x, y, z) distance for all parts 
        [~, ind] = min(temp_dist(:));
        [~, ind_col] = ind2sub(size(temp_dist), ind);
        
        ind_row = whichPart(temp_partition, row(ind_col, :));
        org_row(ind_row, :) = row(ind_col, :);
        
        % replace used column and row to nan        
        temp_partition(ind_row, :, :) = nan;
        temp_dist(ind_row, :) = nan;
        temp_dist(:, ind_col) = nan;
    end
    
    
    %update previous row
    for part = 1:parts
        if any(~isnan(org_row(part, :))) && norm(prev_row(part, :) - org_row(part, :)) < tolerance(2) || norm(prev_row(part, :) - hole1) < 20 || norm(prev_row(part, :) - hole2) < 20
            prev_row(part, :) = org_row(part, :);
%             partition = updatePart(part, partition, org_row);
        end
        if norm(prev_row(part, :) - org_row(part, :)) > tolerance(3)
            fprintf('Position exceeded tolerance! Row: %d, Col: %d - %d\n',...
                        abs_row, 3*(part-1) + 1, 3*(part-1) + 3);
            
            org_row(part, :) = nan;
        end
    end
    
end


function [org_pos, combTotal] = combSum(dist, col_ind, temp_org_pos)
    global parts
    
    org_pos = temp_org_pos;
    if col_ind > parts
        combTotal = 0;
    elseif isnan(dist(:, col_ind))
        [org_pos, combTotal] = combSum(dist, col_ind+1, temp_org_pos);
    else
        combTotal = intmax;
        for part = 1:parts
            if ~isnan(dist(part, col_ind))
                temp_dist = dist;                
                temp_dist(part, :) = nan;
                temp_dist(:, col_ind) = nan;
                
                temp_org_pos(col_ind) = part;
                [temp_org_pos, nextCombTotal] = combSum(temp_dist, col_ind+1, temp_org_pos);
                
                if combTotal > dist(part, col_ind) + nextCombTotal
                    combTotal = dist(part, col_ind) + nextCombTotal;
                    org_pos = temp_org_pos;
                end
            end
        end
    end
end

function part = whichPart(partition, row_part)
    global parts
    global dimens
    
    total = nan(1, parts);
    %update partition row
    for part = 1:parts        
        for dimen = 1:dimens
            min_part = partition(part, dimen, 1);
            max_part = partition(part, dimen, 2);
            val = row_part(dimen);
            
            if ~isnan(min_part) && ~isnan(min_part)
                if isnan(total(part))
                    total(part) = 0;
                end
                % out of range
                if (val < min_part) || (max_part < val)
                    total(part) = total(part) + min(abs(min_part - val), abs(val - max_part));                
                end
            end
        end
    end
    % get position of suitable part
    part = find(total==min(total));
    part = part(1);
end

function partition = updatePart(part, partition, org_row)
    global parts
    global dimens
    
    %update partition row
%     for part = 1:parts
        for dimen = 1:dimens
        	partition(part, dimen, 1) = min(partition(part, dimen, 1), org_row(part, dimen));
        	partition(part, dimen, 2) = max(partition(part, dimen, 2), org_row(part, dimen));
        end
%     end    
end

function row = reshape_2to1(row_2d)
    global row_length
    
    % reshape 2d row to 1d row
    row = reshape(transpose(row_2d), 1, row_length);
end

function row_2d = reshape_1to2(row)
    global dimens
    global parts
    
    % reshape 1d row to 2d row
    row_2d = transpose(reshape(row, dimens, parts));
end


function in = inhull(testpts,xyz,tess,tol)
% inhull: tests if a set of points are inside a convex hull
% usage: in = inhull(testpts,xyz)
% usage: in = inhull(testpts,xyz,tess)
% usage: in = inhull(testpts,xyz,tess,tol)
%
% arguments: (input)
%  testpts - nxp array to test, n data points, in p dimensions
%       If you have many points to test, it is most efficient to
%       call this function once with the entire set.
%
%  xyz - mxp array of vertices of the convex hull, as used by
%       convhulln.
%
%  tess - tessellation (or triangulation) generated by convhulln
%       If tess is left empty or not supplied, then it will be
%       generated.
%
%  tol - (OPTIONAL) tolerance on the tests for inclusion in the
%       convex hull. You can think of tol as the distance a point
%       may possibly lie outside the hull, and still be perceived
%       as on the surface of the hull. Because of numerical slop
%       nothing can ever be done exactly here. I might guess a
%       semi-intelligent value of tol to be
%
%         tol = 1.e-13*mean(abs(xyz(:)))
%
%       In higher dimensions, the numerical issues of floating
%       point arithmetic will probably suggest a larger value
%       of tol.
%
%       DEFAULT: tol = 0
%
% arguments: (output)
%  in  - nx1 logical vector
%        in(i) == 1 --> the i'th point was inside the convex hull.
%  
% Example usage: The first point should be inside, the second out
%
%  xy = randn(20,2);
%  tess = convhulln(xy);
%  testpoints = [ 0 0; 10 10];
%  in = inhull(testpoints,xy,tess)
%
% in = 
%      1
%      0
%
% A non-zero count of the number of degenerate simplexes in the hull
% will generate a warning (in 4 or more dimensions.) This warning
% may be disabled off with the command:
%
%   warning('off','inhull:degeneracy')
%
% See also: convhull, convhulln, delaunay, delaunayn, tsearch, tsearchn
%
% Author: John D'Errico
% e-mail: woodchips@rochester.rr.com
% Release: 3.0
% Release date: 10/26/06
% get array sizes
% m points, p dimensions
p = size(xyz,2);
[n,c] = size(testpts);
if p ~= c
  error 'testpts and xyz must have the same number of columns'
end
if p < 2
  error 'Points must lie in at least a 2-d space.'
end
% was the convex hull supplied?
if (nargin<3) || isempty(tess)
  tess = convhulln(xyz);
end
[nt,c] = size(tess);
if c ~= p
  error 'tess array is incompatible with a dimension p space'
end
% was tol supplied?
if (nargin<4) || isempty(tol)
  tol = 0;
end
% build normal vectors
switch p
  case 2
    % really simple for 2-d
    nrmls = (xyz(tess(:,1),:) - xyz(tess(:,2),:)) * [0 1;-1 0];
    
    % Any degenerate edges?
    del = sqrt(sum(nrmls.^2,2));
    degenflag = (del<(max(del)*10*eps));
    if sum(degenflag)>0
      warning('inhull:degeneracy',[num2str(sum(degenflag)), ...
        ' degenerate edges identified in the convex hull'])
      
      % we need to delete those degenerate normal vectors
      nrmls(degenflag,:) = [];
      nt = size(nrmls,1);
    end
  case 3
    % use vectorized cross product for 3-d
    ab = xyz(tess(:,1),:) - xyz(tess(:,2),:);
    ac = xyz(tess(:,1),:) - xyz(tess(:,3),:);
    nrmls = cross(ab,ac,2);
    degenflag = false(nt,1);
  otherwise
    % slightly more work in higher dimensions, 
    nrmls = zeros(nt,p);
    degenflag = false(nt,1);
    for i = 1:nt
      % just in case of a degeneracy
      % Note that bsxfun COULD be used in this line, but I have chosen to
      % not do so to maintain compatibility. This code is still used by
      % users of older releases.
      %  nullsp = null(bsxfun(@minus,xyz(tess(i,2:end),:),xyz(tess(i,1),:)))';
      nullsp = null(xyz(tess(i,2:end),:) - repmat(xyz(tess(i,1),:),p-1,1))';
      if size(nullsp,1)>1
        degenflag(i) = true;
        nrmls(i,:) = NaN;
      else
        nrmls(i,:) = nullsp;
      end
    end
    if sum(degenflag)>0
      warning('inhull:degeneracy',[num2str(sum(degenflag)), ...
        ' degenerate simplexes identified in the convex hull'])
      
      % we need to delete those degenerate normal vectors
      nrmls(degenflag,:) = [];
      nt = size(nrmls,1);
    end
end
% scale normal vectors to unit length
nrmllen = sqrt(sum(nrmls.^2,2));
% again, bsxfun COULD be employed here...
%  nrmls = bsxfun(@times,nrmls,1./nrmllen);
nrmls = nrmls.*repmat(1./nrmllen,1,p);
% center point in the hull
center = mean(xyz,1);
% any point in the plane of each simplex in the convex hull
a = xyz(tess(~degenflag,1),:);
% ensure the normals are pointing inwards
% this line too could employ bsxfun...
%  dp = sum(bsxfun(@minus,center,a).*nrmls,2);
dp = sum((repmat(center,nt,1) - a).*nrmls,2);
k = dp<0;
nrmls(k,:) = -nrmls(k,:);
% We want to test if:  dot((x - a),N) >= 0
% If so for all faces of the hull, then x is inside
% the hull. Change this to dot(x,N) >= dot(a,N)
aN = sum(nrmls.*a,2);
% test, be careful in case there are many points
in = false(n,1);
% if n is too large, we need to worry about the
% dot product grabbing huge chunks of memory.
memblock = 1e6;
blocks = max(1,floor(n/(memblock/nt)));
aNr = repmat(aN,1,length(1:blocks:n));
for i = 1:blocks
   j = i:blocks:n;
   if size(aNr,2) ~= length(j),
      aNr = repmat(aN,1,length(j));
   end
   in(j) = all((nrmls*testpts(j,:)' - aNr) >= -tol,1)';
end
end
