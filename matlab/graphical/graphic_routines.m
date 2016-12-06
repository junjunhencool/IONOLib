
function graphic_routines(gtype, spc, cspc, header, dbrange, time, xx, yy, curr_block)

    ipp = header.ipp/1.5e5; lambda = 6; fs = 1/ipp; vmax = fs * lambda/2;
    velocity = vmax * ([0 : header.num_prof - 1] - header.num_prof / 2) / header.num_prof;
    height = header.spacing * [0 : header.num_hei - 1] + header.first_height;
    
    rvel_range = [min(velocity) max(velocity)];
    
    for i = 1 : numel(gtype)
        
        switch gtype(i)
            
            case 1
                
            case 2
               
                yvalues = height;
                
%                hvalues = (1:8) * 100;
                hvalues = (1:8) .* 15 + 75;
                
                for k = 1 : numel(hvalues)
                    [dummy, tmp_hval_ind] = min(abs(yvalues - hvalues(k)));
                    if k == 1, hval_ind = tmp_hval_ind; else ...
                            hval_ind = cat(1, hval_ind, tmp_hval_ind); end;
                end
                
                title = [cat(2, num2str(yvalues(hval_ind)','%03i'), ...
                    repmat(' km', numel(hval_ind), 1))];
                
                texts = struct('main_title', ['JRO Spectra: ' time 'LT'], ...
                    'legend', ['Channel 1'; 'Channel 2']);
                xtitle = 'm/s';
                
                plot_panels(velocity, 10*log10(spc(:, hval_ind, :)), ...
                    rvel_range, dbrange, gtype(i), texts, title, xtitle, ...
                    xx, yy, curr_block);
                                
            case 3
                
        end
        
    end
