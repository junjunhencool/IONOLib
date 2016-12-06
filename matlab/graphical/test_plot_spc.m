
function test_plot_spc

    clear global; close all;
    
    if strcmp(computer,'GLNX86'), root_dir = '/media/sda5'; ...
            else root_dir = 'D:'; end;

    dpath = [root_dir '/Users/rilma/work/database/drifts/'];
    gpath = [root_dir '/Users/rilma/work/temp/'];
    year = 2004; doy = 160; show_incoh = 0; show_cspc = 0;
  
    dbrange = [25 40]; gtype = [2];
    dbrange = [15 120];
 
    [month, dom, month_name] = get_date(year,doy);
    maindpath = [dpath 'Drifts-data/d' num2str(year,'%04d') num2str(month,'%02d') num2str(dom,'%02d') '/'];
    ftype = '*.*min_specs';
 
    fname = dir([maindpath ftype]);
    
    for i = 1 : numel(fname)
        
        tmp_fid = str2num(fname(i).name(1, 1 : strfind(fname(i).name,'.') - 1));
        
        if i == 1, file_id = tmp_fid; else ...
                file_id = cat(1, file_id, tmp_fid); end;
        
    end
    
    [sort_file_id, sort_ix] = sort(file_id);
 
    header = header_specs(year, doy);

% Converting IPP from range to time units
%       (1ms -> 150 km)
    lspeed = 3.0e8; % Speed of light [m/s]
    rtime = 1e-3; % Reference time [s];    
    range2time_ipp_factor = lspeed * rtime / 2;
    ipp = header.ipp / range2time_ipp_factor; % [s]
%

% Radar wavelength
%
    rfreq = 50e6; % Radar operation frequency [Hz]
    rlambda = lspeed / rfreq; % [m]
%    

% Sampling frequency
%
    fs = 1.0 / ipp; % [Hz]
%

% Doppler Shift (interval size)
%

    dbins = ((0 : header.num_prof - 1) - header.num_prof / 2)' ;
    
    % velocity
    %
    dv_isize = fs * rlambda / 2; % [m/s]    
    dvel = dv_isize * dbins / header.num_prof;  % [m/s]
    %
    
    % frequency
    %
    dfreq = fs * dbins / header.num_prof; % [Hz]
    %
    
    %
    height = (header.spacing * (0 : header.num_hei - 1) + ...
        header.first_height)';
    %
    
    for i = 1 : numel(fname)
     
        filename = [maindpath fname(sort_ix(i)).name];
%        [time, data] = read_min_specs(filename, header);
        [time, spc] = read_jro_drifts_specs(filename, header);        

        disp(filename);
     
%        data = double(data);               
        spc = double(spc);
     
        spc_data = repmat(NaN,[header.num_prof header.num_hei header.num_chan]);
        cspc_data = repmat(NaN,[header.num_prof header.num_hei header.num_pairs]);
        
        for ich = 1 : header.num_chan
         
%            spc_data(:,:,ich) = permute(data(:,ich,:,1),[1,3,2]);
            spc_data(:,:,ich) = spc(:,:,ich);
 %           if ~(show_incoh==1), spc_data(:,:,ich) = spc_data(:,:,ich) + ...
 %                   permute(data(:,10+ich,:,1),[1,3,2]); end;

%         cb_id = colorbar('vert');         
         
        end
          
        if show_cspc == 1
         
%            cspc_data = permute(data(:,5,:,1),[1,3,2]);
%         spcA = permute(data(:,1,:,1),[1,3,2]); spcB = permute(data(:,2,:,1),[1,3,2]);
%%%     if coherent 
%         cspc = cspc + permute(data(:,15,:,1),[1,3,2]);
%         spcA = spcA + permute(data(:,11,:,1),[1,3,2]); 
%         spcB = spcB + permute(data(:,12,:,1),[1,3,2]);
%%%     end
%         ccf = cspc ./ sqrt(spcA.*spcB);
%         subplot(1,4,3);
%         imagesc(vel,hei,abs(ccf)',[0,1]); title('Coherence');
%         axis xy; colorbar('vert');
%         subplot(1,4,4);
%         imagesc(vel,hei,angle(ccf)',[-pi,pi]); title('Phase');
%         axis xy; colorbar('vert');
         
        else cspc = [];
        end
   
%     xx = struct('Label', 'm/s', 'Tick', get(pn_id, 'XTick'), ...
%         'TickLabel', get(pn_id, 'XTickLabel'));
%     yy = struct('Label','dB','Tick', get(cb_id, 'YTick'), ...
%         'TickLabel', get(cb_id, 'YTickLabel'));
     
%     graphic_routines(gtype, spcs, cspc, header, dbrange, time, xx, yy, i);

        [yy,mm,dd,hh,mi,ss] = datevec(time);

        fign = 1;
        h = plot_spc(fign,spc_data,[],dfreq,height,time,header);
        
        graph = 1; fig_resolution = 100;
        spcfn_format = '%04i%02i%02i%02i%02i%02i';
        figfile = ['spc_' num2str([yy mm dd hh mi ss],spcfn_format)];
        save_figure(h, graph, fig_resolution, [gpath figfile]);
       
        
        drawnow;
     
    end
   
     
% end

function h = plot_spc(fign,spc,cspc,spcfreq,spcrange,time,header)

    dfinc = 50.0;
%    dfreq_range = [-1 1] * max(abs(spcfreq));
    dfreq_range = [min(spcfreq) max(spcfreq)];
    dfreq_ticks = (0:dfinc:max(abs(spcfreq)));
    dfreq_ticks = [-dfreq_ticks((numel(dfreq_ticks):-1:2)) dfreq_ticks];
    ind = find(dfreq_ticks >= dfreq_range(1) & dfreq_ticks <= dfreq_range(2));
    if ~isempty(ind), dfreq_ticks = dfreq_ticks(ind); end;
    
    rinc = 200;
    ran_range = [min(spcrange) max(spcrange)];
    ran_ticks = (10*floor(ran_range(1)/10):rinc:10*ceil(ran_range(2)/10));
    ind = find(ran_ticks >= ran_range(1) & ran_ticks <= ran_range(2));
    if ~isempty(ind), ran_ticks = ran_ticks(ind); end;
    
    myFontName = 'new century schoolbook';
    myFontSize = 10;

    [nfreq,nran,nchan] = size(spc);
    
    ncols = ceil(nchan / 2); nrows = ceil(nchan / ncols);

    mychlabels(1) = {'1'}; mychlabels(2) = {'2'}; mychlabels(3) = {'3'};
    mychlabels(4) = {'4'};
    try if isempty(chlabels), chlabels = mychlabels; end; 
    catch chlabels = mychlabels; end;
    
    bottom_color = 1; top_color = 64;
    zmin_val = 20; zmax_val = 40; myXLim_prof_inc = 10;
    zrange = [zmin_val zmax_val]; zinc = myXLim_prof_inc/2;
    show_powprof = 1;
    
    h = figure(fign); clf(h, 'reset');
    
    fig_xsize = 300 * (1 + 0.35*(show_powprof > 0)); fig_ysize = 500;
    npanels = nchan; % + ...
    pcounter = 0;
    
    fig_position = [10 40 fig_xsize*ncols fig_ysize*nrows];
    set(h, 'Position', fig_position);
       
% With (horizontal) and without (vertical) space between panels
%
    x0 = 0.10; xf = 0.95; y0 = 0.15; yf = 0.90;
    wp_factor = 0.95; lp_factor = 0.0; hp_factor = 0.875; bp_factor = 1.0;
%    

    xsize_panel = (xf - x0) / ncols; ysize_panel = (yf - y0) / nrows;
    
    if show_powprof == 1
        wp_factor = 0.6; wp_prof_factor = 0.3; % 0.95 - 0.65
        width_prof_panel = wp_prof_factor * xsize_panel;
    end    
    
    width_panel = wp_factor * xsize_panel; height_panel = hp_factor * ysize_panel;
                                       
    for i = 1 : nrows

%        left_panel = x0 + (lp_factor + (i - 1)) * xsize_panel;
        bottom_panel = yf - i * ysize_panel * bp_factor;
        
        for j = 1 : ncols            

            left_panel = x0 + (lp_factor + (j - 1)) * xsize_panel;           
%            bottom_panel = yf - j * ysize_panel * bp_factor;
            
            panel_position = [left_panel bottom_panel width_panel height_panel];

            subplot('Position', panel_position);
            
            if pcounter <= npanels
                
                myXLim = dfreq_range; myXTick = dfreq_ticks;
                for j1 = 1 : numel(myXTick)
                    if i == ncols, myXTickLabel(j1) = {num2str(myXTick(j1))}; else ...
                        myXTickLabel(j1) = {' '}; end;
                end
            
                myYLim = ran_range; myYTick = ran_ticks;  
                for j2 = 1 : numel(myYTick)
                    if j == 1, myYTickLabel(j2) = {num2str(myYTick(j2))}; else ...
                        myYTickLabel(j2) = {' '}; end;
                    myYTickLabel_prof(j2) = {' '};
                end

                myXLim_prof = [zmin_val zmax_val];
                myXTick_prof = myXLim_prof(1) : myXLim_prof_inc : myXLim_prof(2);
                for j3 = 1 : numel(myXTick_prof)
                    if i == ncols, myXTickLabel_prof(j3) = {num2str(myXTick_prof(j3))}; else ...
                            myXTickLabel_prof(j3) = {' '}; end;
                end
                
                zvalues = 10.*log10(spc(:,:,pcounter+1));
                
                cvalues = bottom_color + round((top_color - bottom_color) * ...
                    (zvalues - zmin_val) / (zmax_val - zmin_val)) + 1;
                
                image(spcfreq,spcrange,cvalues');

                set(gca, 'FontName', myFontName, 'FontSize', myFontSize,...
                    'XLim', myXLim, 'XMinorTick', 'on', ...
                    'XTick', myXTick, 'XTickLabel', myXTickLabel, ...
                    'YLim', myYLim, 'YMinorTick', 'on', ...
                    'YTick', myYTick, 'YTickLabel', myYTickLabel);
                
                title(['Ch ' chlabels{1,pcounter+1}]);
                if j == 1, ylabel('Range (km)'); else ylabel(' '); end;
                if i == nrows, xlabel('Hz'); else xlabel(' '); end;
                grid on; axis xy;
           
                if show_powprof == 1
                    
                    left_prof_panel = (x0 + 1.05*width_panel) + ...
                        (lp_factor + (j - 1)) * xsize_panel;                   
                    panel_prof_position = [left_prof_panel bottom_panel ...
                        width_prof_panel height_panel];

                    subplot('Position', panel_prof_position);
                    
                    pow_prof = sum(spc(:,:,pcounter+1),1)./nfreq;
                                        
                    pow_prof_db = 10.*log10(pow_prof);
                    line(pow_prof_db, spcrange, 'Color', 'k', 'LineWidth', 2);
                    
                    [noise, nloops] = enoise(pow_prof, header.num_incoh*header.num_prof);
                    noise_db = 10.0*log10(noise);
                    line(repmat(noise_db, 2), myYLim, 'Color', 'k', ...
                        'LineStyle', '--', 'LineWidth', 1);
                    
                    set(gca, 'FontName', myFontName, 'FontSize', myFontSize,...
                        'XLim', myXLim_prof, 'XMinorTick', 'on', ...
                        'XTick', myXTick_prof, 'XTickLabel', myXTickLabel_prof, ...
                        'YLim', myYLim, 'YMinorTick', 'on', ...
                        'YTick', myYTick, 'YTickLabel', myYTickLabel_prof);

                    title(['Noise: ' num2str(noise_db,'%6.2f') ' dB']); 
                    ylabel(' ')
                    if i == nrows, xlabel('dB'); else xlabel(' '); end;
                    
                    grid on;
                    
                end
                
            end                        
            
            pcounter = pcounter + 1;

            if i == 1 & j == 1
                
                ut = 0;
                tz_title = [' (LT)';' (UT)'];               
                myTextDate = ['Date: ' datestr(time,0) tz_title(ut+1,:)];
                
                text(2.0*ncols*width_panel, 1.20, ...
                    myTextDate, 'FontName', myFontName, ...
                    'FontSize', 1.5*myFontSize, 'HorizontalAlignment','center', ...
                    'Units', 'normalized');
                
            end
            
%            disp(['Stop!']);
            
        end
        
%        disp(['Stop!']);
        
    end
   
    
    cmp_left = x0 + (lp_factor + (1 - 1)) * xsize_panel;
    cmp_bottom = yf - nrows * ysize_panel * bp_factor - 0.075;   
    cmp_width = width_panel; cmp_height = 0.05*height_panel;
    
    cmp_position = [cmp_left cmp_bottom cmp_width cmp_height];  
    
    colorscale([bottom_color top_color], zrange, zinc, ...
        'horizontal', 'Position', cmp_position);
    
    set(gca,'FontName',myFontName,'FontSize',myFontSize, ...
        'XMinorTick','on');
    xlabel('dB');
        

%disp(['Stop!']);

% function noise = get_noise(power, nprof)
% 
%     ndata = numel(power);
%     
%     data_sorted = double(sort(power,'ascend'));
%     
%     if uint32(ndata/10) > 0
%         nums_min = 
%     else
%     end