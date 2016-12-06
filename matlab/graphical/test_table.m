    
    trange = datenum(2004,11,[9 10],[0 23],[0 59],[0 59]);
    graph = 1;

    if strcmp(computer,'GLNX86'), root_dir = '/media/sda5'; ...
            else root_dir = 'D:'; end;    
    gpath = [root_dir '/Users/rilma/work/temp/'];

    pars = [31]; i = 1; j = 1;
    
    fig = 1;

    nrows = numel(pars); ncols = 1;
    
    fig_xsize = 1100; 
    fig_ysize = nrows * (700 * (nrows <= 2) + 180 * (nrows > 2)) ;  
    
% With spaces between panels
%
    x0 = 0.00; xf = 1.0; y0 = 0.0; yf = 1.0;
    wp_factor = 0.65; lp_factor = 0.15; hp_factor = 0.75; bp_factor = 0.85 + 0.05 * (nrows > 2);
%
    figh1 = figure(fig); clf(figh1, 'reset');    
    
    fig_position = [10 40 fig_xsize*ncols fig_ysize];
    set(figh1, 'Position', fig_position);
   
    xsize_panel = (xf - x0) / ncols; ysize_panel = (yf - y0) / nrows;    
    width_panel = wp_factor * xsize_panel; height_panel = hp_factor * ysize_panel;        
        
    left_panel = x0 + (lp_factor + (i - 1)) * xsize_panel;           
    bottom_panel = yf - j * ysize_panel * bp_factor;
            
    panel_position = [left_panel bottom_panel width_panel height_panel];

    subplot('Position', panel_position);

%---------------------------------------------------------------------    
    left_table = 1.02 * (left_panel + width_panel) * fig_xsize;
    bottom_table = bottom_panel * fig_ysize;
    width_table = 0.5 * (1 - wp_factor) * fig_xsize;
    height_table = height_panel * fig_ysize;
    table_position = [left_table bottom_table width_table height_table];

    if strcmp(computer,'GLNX86'), root_dir = '/media/sda5'; ...
            else root_dir = 'D:'; end;    
    dpath_champ = [root_dir '/Users/rilma/work/database/satellites/champ/'];
    fname = 'data_mk_set01.txt';
    champ_data = read_champ_nov2004([dpath_champ fname]);
    
    ind = find(champ_data.time >= trange(1) & champ_data.time <= trange(2));
    
    numdata = length(champ_data.time(ind));
    tmp0 = num2cell([1:numdata]');
    tmp1 = cellstr(datestr(champ_data.time(ind), 'HH:MM'));
    tmp2 = num2cell(champ_data.longitude(ind));
    tmp = cell(numdata, 3);
    
    [tmp{:,1}] = tmp0{:,1};
    [tmp{:,2}] = tmp1{:,1};
    [tmp{:,3}] = tmp2{:,1};

    cell_data = tmp;        
%---------------------------------------------------------------------    

tbl = axes('units', 'pixels','position', table_position);

columninfo.titles={' ','UT','Longitude'};
%columninfo.formats = {'%4.6g','%4.6g','%4.6g'};
columninfo.formats = {'%4.6g','%4.6g','%7.2f'};
columninfo.weight = [ 1, 1, 1];
columninfo.multipliers = [ 1, 1, 1];
columninfo.isEditable = [ 1, 1, 1];
columninfo.isNumeric = [ 1, 0, 1];
columninfo.withCheck = false;
columninfo.chkLabel = 'Use';
rowHeight = 4;
gFont.size = 9;
gFont.name = 'Helvetica';

cu_mltable(fig, tbl, 'CreateTable', columninfo, rowHeight, cell_data,...
gFont);
     
save_figure(figh1, graph, 600, [gpath 'champ_table']);
