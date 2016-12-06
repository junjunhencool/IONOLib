function data = read_ao_drift(fname, verbose)

    if isempty(fname)
        
        dpath = '/home/rilma/work/database/ao';
        fname = [dpath filesep 'ao_vels_11092004-11102004.dat'];

    end
    
    if isempty(verbose), verbose = 1; end;

    fid = fopen(fname, 'r');

%        info = fread(fid, 3, 'int32');
        info = fread(fid, 3, 'single');
        tmp_time = fread(fid, info(1), 'double');
        altitude = fread(fid, info(2), 'double');
        
        vap = fread(fid, info(1)*info(2), 'double');
        vap = reshape(vap, info(1), info(2));
        
        vpn = fread(fid, info(1)*info(2), 'double');
        vpn = reshape(vpn, info(1), info(2));
        
        vpe = fread(fid, info(1)*info(2), 'double');
        vpe = reshape(vpe, info(1), info(2));
        
    fclose(fid);       
    
    hour = double(floor(tmp_time)); minute = double(floor(60 * (tmp_time - hour))); 
    second = double(floor(60 * (60 * (tmp_time - hour) - minute)));
       
    month = str2num(fname(numel(fname)-20:numel(fname)-19));
    dom = str2num(fname(numel(fname)-18:numel(fname)-17));
    year = str2num(fname(numel(fname)-16:numel(fname)-13));
    
    time = datenum(year, month, dom, hour, minute, second);
    
    data = struct('time', time, 'altitude', altitude, 'vap', vap, ...
        'vpn', vpn, 'vpe', vpe);
