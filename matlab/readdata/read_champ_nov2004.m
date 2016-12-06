    
function output = read_champ_nov2004(filename)

    fileinfo = dir(filename);
    iseof = 0; tmp = [];
    
    fid = fopen(filename, 'r');
    
        for i = 1 : 13, iseof = fgets(fid); end;
        
        while (iseof ~= (-1))
            
            iseof = fgets(fid);
            tmp0 = sscanf(iseof, '%f');
            
            if isempty(tmp), tmp = tmp0; else ...
                    tmp = cat(2, tmp, tmp0); end;
            
            if ftell(fid) >= fileinfo.bytes, iseof = -1; end;
            
        end
        
    fclose(fid);
        
    output = struct('time', (tmp(1, :) + datenum(2000,1,1,0,0,0))', ...
        'efield', tmp(6, :)' .* 1e3, 'longitude', tmp(2, :)', ...
        'local_time', tmp(4, :));
    