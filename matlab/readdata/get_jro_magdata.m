function output = get_jro_magdata(dpath, trange, type)

    fnames = [];
    str_station = ['jic'; 'piu'; 'j-p'];
    
    tdates = trange(1) : 1 : trange(2);
    dt = datevec(tdates);
    
    for i = 1 : length(tdates)
        stryy = num2str(dt(i, 1)); strdd = num2str(dt(i, 3), '%02i');
        strmm = lower(datestr(tdates(i), 'mmm'));
        tmpfname = [dpath str_station(type, :) stryy(3:4) filesep ...
            str_station(type, :) strdd strmm '.' stryy(3:4) 'm'];
        fileinfo =dir(tmpfname);
        if ~isempty(fileinfo)
            if isempty(fnames), fnames = tmpfname; else ...
                fnames = cat(1, fnames, tmpfname); end;
        end
    end
    
    for i = 1 : size(fnames, 1)
        tmp = read_jro_magdata(fnames(i, :));
        disp(['Reading: ' fnames(i, :)]);
        if i == 1
            output = tmp;
        else
            fn = fieldnames(output);
            for j = 1 : length(fn)
                fv = cat(1, getfield(output, fn{j, 1}), getfield(tmp, fn{j, 1}));
                output = setfield(output, fn{j, 1}, fv);
            end
        end
    end
    
function output = read_jro_magdata(filename)

    fid = fopen(filename, 'r');
        tmp = textscan(fid, '%f %f %f %f %f %f %f %f', 'HeaderLines', 4);
    fclose(fid);
    time = datenum(tmp{1,3}, tmp{1,2}, tmp{1,1}, tmp{1,4}, tmp{1,5}, 0);
    
    ind_if = find(isfinite(tmp{1,6}) == 1);
    if isempty(ind_if), ind_if = 1:length(tmp{1,6}); end;
                
    output = struct('time', time(ind_if), 'D', tmp{1,6}(ind_if), ...
        'H', tmp{1,7}(ind_if), 'Z', tmp{1,8}(ind_if));
    