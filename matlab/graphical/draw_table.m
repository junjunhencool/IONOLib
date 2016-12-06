
function draw_table(data, fig_size, panel_position, wp_factor, sel_index, ...
    fig_number)

    if isunix, myFontName = 'new century schoolbook'; ...
            else myFontName = 'NewCenturySchoolBook'; end

    champ_data = data;
    fig_xsize = fig_size(1); fig_ysize = fig_size(2);
    left_panel = panel_position(1); bottom_panel = panel_position(2);
    width_panel = panel_position(3); height_panel = panel_position(4);
    ind = sel_index;

    left_table = 1.02 * (left_panel + width_panel) * fig_xsize;
    bottom_table = bottom_panel * fig_ysize;
    width_table = 0.5 * (1 - wp_factor) * fig_xsize;
    height_table = height_panel * fig_ysize;
    table_position = [left_table bottom_table width_table height_table];
    
    numdata = length(champ_data.time(ind));
    column1 = cellstr(cat(2, cat(2,repmat('(',numdata,1), ...
        num2str([1:numdata]')),repmat(')',numdata,1)));
    column2 = cellstr(datestr(champ_data.local_time/24, 'HH:MM:SS'));
    column3 = num2cell(champ_data.longitude(ind));
    table_data = cell(numdata, 3);
    
    [table_data{:,1}] = column1{:,1}; [table_data{:,2}] = column2{:,1};
    [table_data{:,3}] = column3{:,1};

    tbl = axes('units', 'pixels','position', table_position);

    columninfo.titles={'Number','LT','Longitude'};
    columninfo.formats = {'%4.6g','%4.6g','%7.2f'};
    columninfo.weight = [ 1, 1, 1];
    columninfo.multipliers = [ 1, 1, 1];
    columninfo.isEditable = [ 1, 1, 1];
    columninfo.isNumeric = [ 0, 0, 1];
    columninfo.withCheck = false;
    columninfo.chkLabel = 'Use';
    rowHeight = 4;
    gFont.size = 9;
    gFont.name = myFontName;%'new century schoolbook';

    cu_mltable(fig_number, tbl, 'CreateTable', columninfo, ...
        rowHeight, table_data, gFont);           
            
    set(gca, 'FontName', myFontName);
%    title('(b) CHAMP Satellite Pass Info');
    title('(c) CHAMP Satellite Pass Info');
%    title('CHAMP Satellite Pass Info (11/9/2004)');
    