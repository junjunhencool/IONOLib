
function output = load_ace_realtime(trange, path)

    [yy,mm,dd] = datevec(trange);
    
    dtTRange = datenum(yy, mm, dd, 0, 0, 0);
    
    dtDates = dtTRange(1) : dtTRange(2);

    [yy,mm,dd] = datevec(dtDates);
    
    for i = 1 : 2
        switch i
            case 1                
                fname = [num2str(yy', '%04i') num2str(mm', '%02i') ...
                    num2str(dd', '%02i') repmat('_ace_mag_1m.txt', ...
                    numel(yy), 1)];
                type = 1;
            case 2
                fname = [num2str(yy', '%04i') num2str(mm', '%02i') ...
                    num2str(dd', '%02i') repmat('_ace_swepam_1m.txt', ...
                    numel(yy), 1)];
                type = 2;
        end
                
        for j = 1 : numel(dtDates)
            filename = dir([path fname(j, :)]);
            tempdata = read_ace_realtime([path filename.name], type);
            if j == 1
                switch i
                    case 1
                        mag = tempdata;
                    case 2
                        swepam = tempdata;
                end                
            else
                fns = fieldnames(tempdata);
                for jj = 1 : numel(fns)
                    switch i
                        case 1
                            curr_fdata = getfield(mag, fns{jj, 1});
                        case 2
                            curr_fdata = getfield(swepam, fns{jj, 1});                            
                    end
                    fdata = getfield(tempdata, fns{jj, 1});
                    new_fdata = cat(1, curr_fdata, fdata);
                    switch i
                        case 1
                            mag = setfield(mag, fns{jj, 1}, new_fdata);
                        case 2
                            swepam = setfield(swepam, fns{jj, 1}, new_fdata);                            
                    end
                end               
            end
        end
        
    end
    
    output = struct('mag', mag, 'swepam', swepam);
    
    % Replacing bad data with "NaN"
    %
    fn = fieldnames(output);
    for i = 1 : numel(fn)
        fdi = getfield(output, fn{i,1});
        fndi = fieldnames(fdi); fdiS = getfield(fdi, 'S');
        ind = find(fdiS ~= 0);
        if ~isempty(ind)
            for j = 3 : 5
                fdis = getfield(fdi, fndi{j, 1});
                fdis(ind) = NaN;
                fdi = setfield(fdi, fndi{j, 1}, fdis);
            end
            output = setfield(output, fn{i, 1}, fdi);
        end
    end
    %
    
%    disp('Stop!');

function output = read_ace_realtime(filename, type)
    
    if type == 1, myHeaderLines = 20; else myHeaderLines = 18; end;
    disp(['Reading: ' filename]);
    hf = fopen(filename, 'r');
        format = repmat('%f', 1, 13);
        tmp = textscan(hf, format, 'HeaderLines', myHeaderLines);        
    fclose(hf);
    
    time = datenum(tmp{1,1},tmp{1,2},tmp{1,3},0,0,0) + tmp{1,6} / 86400.0;
    
    if type == 1
        output = struct('time', time, 'S', tmp{1,7}, ...
            'Bx', tmp{1,8}, 'By', tmp{1,9}, 'Bz', tmp{1,10}, ...
            'latitude', tmp{1,12}, 'longitude', tmp{1,13});
    else
        output = struct('time', time, 'S', tmp{1,7}, ...
            'density', tmp{1,8}, 'speed', tmp{1,9}, 'temperature', tmp{1,10});
    end
    