function output = time_axis_format(trange, step_size)

    [year, month, dom] = datevec(datestr(trange));
    
    tmp_step_size = (1/24) * step_size;
    
    tmp_trange = datenum(year, month, dom, [0; 23], [0; 59], [0; 59]);
    
    num_steps = (tmp_trange(2) - tmp_trange(1)) / tmp_step_size + 1;
    
    tvalues = [0 : num_steps] / (num_steps - 1) * (tmp_trange(2) - ...
        tmp_trange(1)) + tmp_trange(1);
    tvalues = tvalues(find(tvalues >= trange(1) & tvalues <= trange(2)));
    
    ticklabel = datestr(tvalues, 'HH:MM');
    
    if month(1) == month(2)
        
        label = [datestr(trange(1), 'mm/dd') '-' ...
            datestr(trange(2), 'dd') '/' datestr(trange(1), 'yyyy')];
     
        if dom(1) == dom(2), label = datestr(trange(1), 'mm/dd/yyyy'); end;
    
    else
        label = [datestr(trange(1), 'mm/dd/yyyy') ' - ' ...
            datestr(trange(1), 'mm/dd/yyyy')];
    end
     
    output = struct('Label', label, 'Lim', trange, 'Tick', tvalues, ...
        'TickLabel', ticklabel);
