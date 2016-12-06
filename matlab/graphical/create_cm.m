function map = create_cm(n)

    if nargin < 1, n = 1; end;
    
%    myPath = ['.' filesep];
    myPath = [pwd filesep 'graphical' filesep];

    % Black and White colors
    bkwh = [[0.0 0.0 0.0]; [1.0 1.0 1.0]];

    switch n
        case 1
            fname = [myPath 'newcol_koki.txt'];
            baseMap = read_mapdata(fname, 1);
        case 2
%
% Light Blue - Blue - Green - Yellow - Red
% Indices: 001 - 048
%             
            fname = [myPath 'cmap01.mat']; load(fname, 'mycmap');
%            
% Blue - Red
% Indices: 049 - 112
%            
%            mycmap01 = lbmap(64, 'RedBlue');
            
            fname = [myPath 'cmap02.mat']; 
            mycmap_struct = load(fname, 'mycmap');
            
            [ncol0, ncomp0] = size(mycmap_struct.mycmap);
            baseMap = cat(1, mycmap, mycmap_struct.mycmap([ncol0:-1:1],:));
            
%
%   Adding black and white colors (indices 113 and 114, respectively)
%
            tmp_colors = [[0.0 0.0 0.0];[1.0 1.0 1.0]];
            baseMap = cat(1, baseMap, tmp_colors);
            
            tmp_cmap = colormap('Jet');
            baseMap = cat(1, baseMap, tmp_cmap);
            
        case 3

            % Joining "Hot" and "Jet" color tables
            baseMap = cat(1, colormap('Hot'), colormap('Jet'));
            
    end

    % Adding black and white colors at the end
    baseMap = cat(1, baseMap, bkwh);
    
    map = baseMap;

function baseMap = read_mapdata(filename, verbose)

    fileinfo = dir(filename);

    if isempty(verbose), verbose = 1; end;

    fid = fopen(filename, 'rt');
    
        if verbose == 1, disp(['Reading: ' filename]); end;
        
        counter = 0; iseof = 0;
        
        for i = 1 : 4, dummy = fgets(fid); end;
        
        while iseof~=(-1)
            
            iseof = fgets(fid); tmp_strline = iseof;
            
            tmp_col = [str2num(tmp_strline(5:8)) ...
                str2num(tmp_strline(9:12)) ...
                str2num(tmp_strline(13:16))];
            
            if counter == 0
                colors = tmp_col;
            else
                colors = cat(1, colors, tmp_col);
            end
 
            if (ftell(fid) >= fileinfo.bytes), iseof = -1; end;
            
            counter = counter + 1;
            
        end
        
    fclose(fid);
    
    baseMap = colors / 255;
    