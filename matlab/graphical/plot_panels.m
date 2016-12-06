function plot_panels(xvalues, yvalues, xlim, ylim, fid, texts, ptitle, xtitle, ...
    xx, yy, curr_block)

    [nx, npanels, nlines] = size(yvalues);
    
    ncols = ceil(sqrt(npanels)); nrows = ceil(npanels/ncols);
    
    fig_xsize = 300; fig_ysize = 160;
    fontsize = 7; pcounter = 1; font_name = 'new century schoolbook';
    colors = ['r';'g';'b'];

% With (horizontal) and without (vertical) space between panels
%
     x0 = 0.10; xf = 0.95; y0 = 0.10; yf = 0.90;
     wp_factor = 0.95; lp_factor = 0.0; hp_factor = 0.95; bp_factor = 1.0;
%    

    xx = setfield(xx, 'Lim', xlim);                
    yy = setfield(yy, 'Lim', ylim);    
    
    figh = figure(fid); clf(figh, 'reset');    

    if curr_block == 1
        fig_position = [10 40 fig_xsize*ncols fig_ysize*nrows];
        set(figh, 'Position', fig_position);
    end
       
    xsize_panel = (xf - x0) / ncols; ysize_panel = (yf - y0) / nrows;
    
    width_panel = wp_factor * xsize_panel; height_panel = hp_factor * ysize_panel;
    
    for i = 1 : ncols

        left_panel = x0 + (lp_factor + (i - 1)) * xsize_panel;
        
        for j = 1 : nrows            

            bottom_panel = yf - j * ysize_panel * bp_factor;
            
            panel_position = [left_panel bottom_panel width_panel height_panel];

            subplot('Position', panel_position);
            
            if pcounter <= npanels
                
                for k = 1 : nlines
                    
                    line(xvalues, yvalues(:, pcounter, k), ...
                        'Color', colors(k, :), 'LineWidth', 2);
                    
                end

                grid on; tmp_title = ptitle(pcounter, :);    
                        
            else
                
                tmp_title = '';
                
            end       
            
            if pcounter == 1
                legend(texts.legend);
            end
            
%            if isempty(xx) & i == 1 & j == 1                                                
%            end

            if i > 1
                
                [nyticklabels, lenght_yticklabel] = size(yy.TickLabel);
                yticklabel = repmat(' ', nyticklabels, lenght_yticklabel);
                
                [nylabel, lenght_ylabel] = size(yy.Label);
                tmp_ylabel = repmat(' ', nylabel, lenght_ylabel);
                
            else
                yticklabel = yy.TickLabel; tmp_ylabel = yy.Label;
            end            
            
            if j < nrows
                
                [nxticklabels, lenght_xticklabel] = size(xx.TickLabel);
                xticklabel = repmat(' ', nxticklabels, lenght_xticklabel);
                
                [nxlabel, lenght_xlabel] = size(xx.Label);
                tmp_xlabel = repmat(' ', nxlabel, lenght_xlabel);
                
            else
                xticklabel = xx.TickLabel; tmp_xlabel = xx.Label;
            end
       
            set(gca, 'FontName', font_name, ...
                'FontSize', fontsize, ...%'FontWeight','bold', ...
                'XLim', xx.Lim, 'XMinorTick', 'on', 'XTick', xx.Tick, ...
                'XTickLabel', xticklabel, ...
                'YLim', yy.Lim, 'YMinorTick', 'on', 'YTick', yy.Tick, ...
                'YTickLabel', yticklabel);
            
            title(tmp_title, 'FontName', font_name, ...
                'Fontsize', 1.1*fontsize, 'VerticalAlignment', 'Top'); 
            xlabel(tmp_xlabel, 'FontName', font_name, 'Fontsize', fontsize); 
            ylabel(tmp_ylabel, 'FontName', font_name, 'Fontsize', fontsize);            
            
            set(gca, 'Fontsize', fontsize);
           
            pcounter = pcounter + 1;
            
        end
        
    end

%    text(0.5, 0.95, texts.main_title, 'FontSize', 7);
    