
function plot_image(data, cmpnum, fig_number, figfile, panelsetup)
    
%    try if isempty(cmp), cmp = colormap('Jet'); end; catch cmp = colormap('Jet'); end;
    try if isempty(cmpnum), cmpnum = 1; end; catch cmpnum = 1; end;
    myPanelSetup = struct('size',[1200 307],'type',0);
    try if isempty(panelsetup), panelsetup = myPanelSetup; end; catch ...
            panelsetup = myPanelSetup; end;
    
    if figfile.gftype < 0, return; end;
    
    if isunix == 1, myFontName = 'new century schoolbook'; else ...
            myFontName = 'NewCenturySchoolBook'; end;
    myFontSize = 14 - 0;
%    np_row = 1; np_col = 1;

    fdnames = fieldnames(data); nfields = numel(fdnames);
    if panelsetup.type == 0
        np_row = nfields; np_col = 1;
    else
%        np_row = ???; np_col = ???;
    end

    fid = figure(fig_number); clf(fid, 'reset');
    figHeight = panelsetup.size(2) * np_row;
    if nfields == 1, figHeight = 2.0 * figHeight; end;
    figPosition = [10 40 panelsetup.size(1)*np_col figHeight];
    set(fid, 'Position', figPosition);
   
    cmp = create_cm(cmpnum); [ncolors, dummy] = size(cmp);
    colormap(cmp);
    
%    set(fid, 'PaperUnits', 'centimeters');
    
    % With spaces between panels
    %
    x0 = 0.00; xf = 1.0; y0 = 0.0; yf = 1.0;
    wp_factor = 0.7-0.00; lp_factor = 0.15 - 0.025; hp_factor = 0.75-0.05; bp_factor = 0.85;
    %
    
    xsize_panel = (xf - x0) / np_col; ysize_panel = (yf - y0) / np_row;    
    width_panel = wp_factor * xsize_panel; height_panel = hp_factor * ysize_panel;        

    counter = 1;
    
    for j = 1 : np_row
    
        for i = 1 : np_col
                                        
            curr_data = getfield(data, cell2mat(fdnames(counter)));
            
            bottom_color = curr_data.crange(1); top_color = curr_data.crange(2);
            bottom_zval = curr_data.zlim(1); top_zval = curr_data.zlim(2);
    
            cvalues = bottom_color + round((top_color - bottom_color) * ...
                (curr_data.zvalues - bottom_zval) / (top_zval - bottom_zval)) + 1;    
            
            ind = find(cvalues > top_color);
            if ~isempty(ind), cvalues(ind) = top_color; end;
            ind = find(cvalues < bottom_color);
            if ~isempty(ind), cvalues(ind) = bottom_color; end;
        
            ind = find(~isfinite(curr_data.zvalues));
            if ~isempty(ind), cvalues(ind) = ncolors - 1; end;
            
%        i = 1;
            left_panel = x0 + (lp_factor + (i - 1)) * xsize_panel;

%        j = 1;
            bottom_panel = yf - j * ysize_panel * bp_factor;
            
            panel_position = [left_panel bottom_panel width_panel height_panel];

            subplot('Position', panel_position);
        
            image(curr_data.xvalues, curr_data.yvalues, cvalues');
                        
            htimg = title(curr_data.title); set(htimg, 'FontName', myFontName, ...
                'FontSize', myFontSize);
                        
            switch curr_data.xtype
                
                case 1               
                    datetick('x', 'HH:MM');
                    xx = time_axis_format(curr_data.xlim, curr_data.xinc);
                    
                case 2
                    
                    
            end
            
            if j < np_row
                [nxticklabels, lenght_xticklabel] = size(xx.TickLabel);
                curr_XTickLabel = repmat(' ', nxticklabels, lenght_xticklabel);
                [nxlabel, lenght_xlabel] = size(xx.Label);
                curr_XLabel = repmat(' ', nxlabel, lenght_xlabel);                                
            else 
                curr_XTickLabel = xx.TickLabel;
                curr_XLabel = [xx.Label ' ' curr_data.xlabel];
            end

            hximg = xlabel(curr_XLabel);
            set(hximg, 'FontName', myFontName, 'FontSize', myFontSize);
            hyimg = ylabel(curr_data.ylabel); set(hyimg, ...
                'FontName', myFontName, 'FontSize', myFontSize);
           
            set(gca, 'FontName', myFontName, 'FontSize', myFontSize, ...
                'TickDir', 'out', ...
                'XLim', xx.Lim, 'XMinorTick', 'on', 'XTick', xx.Tick, ...
                'XTickLabel', curr_XTickLabel, ...
                'YLim', curr_data.ylim, 'YMinorTick', 'on');
            axis xy; %grid on;

%%%            if counter == 1
%            if strcmp(curr_data.title, 'SNR + 1, Channel 1') == 1 | ...
%                    strcmp(curr_data.title, 'SNR + 1, Channel 1 (Coh. echoes)') == 1
%                line(curr_data.btl_info.time, curr_data.btl_info.height, ...
%                    'Color', 'r', 'LineStyle', '-', 'LineWidth', 2);
%%%                disp('Stop!');
%            end

             curr_fn = fieldnames(curr_data); wfn = 'tprof';
             ind_tp = find(strcmp(curr_fn, wfn), 1);
             if ~isempty(ind_tp)
                 tp = getfield(curr_data, wfn);
                 tpFN = fieldnames(tp.data);
% %                for k = 1 : 1
% %                for k = 2 : numel(tpFN)
                 for k = 1 : numel(tpFN)
                     if tp.gsetup.graphid(k) > 0                        
                         curr_prof = getfield(tp.data, cell2mat(tpFN(k)));
                         line(curr_data.xvalues, curr_prof.height, ...
                             'Color', 'w', 'LineWidth', 2, ...
                             'Marker', 'x', 'MarkerSize', 2);
%                    disp('Stop!');
                     end
                 end
             end
            
            cmp_left = ((0.87 - 0.02) + 1.0 * (i - 1)) * xsize_panel;
            cmp_width = (0.035) * xsize_panel;
            cmp_position = [cmp_left bottom_panel cmp_width height_panel];
     
            hcmp = colorscale([bottom_color top_color], curr_data.zlim, ...
                curr_data.zinc, 'vert', 'Position', cmp_position);
            hycmp = ylabel(curr_data.ylabelCB); set(hycmp, 'FontName', myFontName, ...
                'FontSize', myFontSize);
            set(hcmp, 'FontName', myFontName, 'FontSize', myFontSize, ...
                'YAxisLocation', 'right')   
 
            counter = counter + 1;
            
        end
    
    end
    
    save_figure(fid, figfile.gftype, figfile.resolution, ...
        figfile.orientation, figfile.filename);
