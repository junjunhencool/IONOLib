function data = read_ao_edens(fname, verbose)
    
    if isempty(fname)
        
        dpath = '/media/sda1/Users/rilma/work/projects/nov2004_superstorm/aro';
        fname = [dpath filesep 'ne09nov2004gr.hdf'];
        
    end
    
    if isempty(verbose), verbose = 1; end;
    
    year = str2num(fname((numel(fname)-9):(numel(fname)-6)));
    
    strmonths = cellstr(lower(datestr(datenum(1970,1:12,1,0,0,0),3)));
    strmonth = fname((numel(fname)-12):(numel(fname)-10));    
    tf = strcmp(strmonth, strmonths); month = find(tf == 1);
    
    dom = str2num(fname((numel(fname)-14):(numel(fname)-13)));
    
    [hts, dtimes, profs] = readhdf_ao_pwr(fname);
    
    hour = double(floor(dtimes)); minute = double(floor(60 * (dtimes - hour))); 
    second = double(floor(60 * (60 * (dtimes - hour) - minute)));
    
    shift_ind = [2:numel(hour), 1];
    icount = find(((hour - hour(shift_ind)) == 23) & ((minute - minute(shift_ind)) == 59));
    icount = cat(1, cat(1, 1, icount), numel(dtimes)); count = numel(icount);
    
    for i = 1:(count-1)
        
        temp_paday = repmat(24 * (i - 1), icount(i + 1) - icount(i) + 1, 1);

        if i == 1
            plus_aday = temp_paday;
        else
            plus_aday = cat(1, plus_aday, temp_paday(1 : (numel(temp_paday) - 1)));
        end
        
    end
    
%    disp(['Stop!']);
    
    jtime = datenum(year, month, dom, hour + plus_aday, minute, second);
    jtime = jtime + 4/24;
    
    ind = find(profs < 0.0); 
    if (~isempty(ind)), profs(ind) = NaN; end;
      
    data = struct('time', jtime, 'altitude', hts, 'edensity', profs);
