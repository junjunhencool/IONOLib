
function plot_panels2(data, fig_number, figfile, panelsetup, plotsetup)

    pcounter = 1;
    fig_xsize = panelsetup.size(1); fig_ysize = panelsetup.size(2);
    
    mfnames = fieldnames(data); nlines = numel(mfnames);    
    
% With (horizontal) and without (vertical) space between panels
%
    x0 = 0.10; xf = 0.95; y0 = 0.10; yf = 0.90+0.05;
    wp_factor = 0.95; lp_factor = 0.0; hp_factor = 0.95-0.1; bp_factor = 1.0;
%    
    
    figh = figure(fig_number); clf(figh, 'reset');    

%     if curr_block == 1
    fig_position = [10 40 fig_xsize*panelsetup.ncols fig_ysize*panelsetup.nrows];
    set(figh, 'Position', fig_position);
%     end
       
    xsize_panel = (xf - x0) / panelsetup.ncols; 
    ysize_panel = (yf - y0) / panelsetup.nrows;
    
    width_panel = wp_factor * xsize_panel; height_panel = hp_factor * ysize_panel;
    
%     for i = 1 : panelsetup.ncols
% 
%         left_panel = x0 + (lp_factor + (i - 1)) * xsize_panel;
%         
%         for j = 1 : panelsetup.nrows            
% 
%             bottom_panel = yf - j * ysize_panel * bp_factor;
        
    for j = 1 : panelsetup.nrows            

        bottom_panel = yf - j * ysize_panel * bp_factor;            

        for i = 1 : panelsetup.ncols

            left_panel = x0 + (lp_factor + (i - 1)) * xsize_panel;            
            
            panel_position = [left_panel bottom_panel width_panel height_panel];
            
            if pcounter <= panelsetup.npanels
                
                subplot('Position', panel_position);              
                
                for k = 1 : nlines
                    fv = getfield(data, cell2mat(mfnames(k)));
                    if k == 1, fv0 = fv; end;
                    xvalues = fv.xvalues(pcounter, :);
                    yvalues = fv.yvalues(pcounter, :);
                    line(xvalues, yvalues, 'Color', fv.color, ...
                        'Marker', fv.marker);
                end
                grid on;
                myTitle = fv0.title(pcounter,:);                
                myLegend = fv0.lglabel(pcounter, :);
                        
            else
                
%                 tmp_title = '';
                
            end       
            
            if pcounter == 1
%                 legend(texts.legend);
            end
            
            set(gca, 'FontName', plotsetup.fontname, ...
                'XLim', plotsetup.xlim, 'XMinorTick', 'on', ...
                'YLim', plotsetup.ylim, 'YMinorTick', 'on');
            xy = get(gca);
            
            if i > 1
                
                [nyticklabels, lenght_yticklabel] = size(xy.YTickLabel);
                yticklabel = repmat(' ', nyticklabels, lenght_yticklabel);
                
                myYLabel = '';
                                
            else
                yticklabel = xy.YTickLabel; 
                myYLabel = plotsetup.ylabel;
            end            
            
            if j < panelsetup.nrows
                
                 [nxticklabels, lenght_xticklabel] = size(xy.XTickLabel);
                 xticklabel = repmat(' ', nxticklabels, lenght_xticklabel);
                 
                 myXLabel = '';
                
            else
                 xticklabel = xy.XTickLabel;
                 myXLabel = plotsetup.xlabel;
            end
       
            set(gca, 'XTickLabel', xticklabel, 'YTickLabel', yticklabel);
            title(myTitle);
            xlabel(myXLabel); ylabel(myYLabel);
           
            pcounter = pcounter + 1;
            
        end
        
    end
    
    save_figure(figh, figfile.gftype, figfile.resolution, ...        
        figfile.orientation, figfile.filename);
 
    