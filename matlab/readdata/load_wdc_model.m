
function output = load_wdc_model(dpath)

    path = dir(dpath);
    
    i0 = 1 + 2;
    
    for i = i0 : numel(path)
        
        fname = [dpath path(i).name];
        prof = read_wdc_model(fname);

        if i == i0
            s0 = prof.s.s0; s1 = prof.s.s1; s2 = prof.s.s2;
            time = prof.time; location = prof.location;
        else
            s0 = cat(2, s0, prof.s.s0); s1 = cat(2, s1, prof.s.s1);
            s2 = cat(2, s2, prof.s.s2);
            time = cat(1, time, prof.time);
            location = cat(2, location, prof.location);
        end
        
        disp(['Reading: ' fname]);
        
    end
    
    output = struct('time', time, 'height', prof.height, ...
        'location', location', 's', struct('s0', s0, 's1', s1, 's2', s2));
    
function output = read_wdc_model(filename)

    format = '%10f %14f %14f %14f';
    
    fid = fopen(filename, 'r');
    
        tmpLine = fgetl(fid);
        tmp = textscan(fid, format, 'HeaderLines', 4);
        
    fclose(fid);
    
    pos = strfind(tmpLine, '=');
    tl = repmat(NaN, numel(pos), 1);    
       
    for i = 1 : numel(pos)
        if i == 6, tmpind = 1:4; else tmpind = 1:5; end;
        tl(i) = str2num(tmpLine(pos(i) + tmpind));
    end
    
    height = tmp{1};    % Height, in km
    s0 = tmp{2};        % Parallel conductivity, in S/m
    s1 = tmp{3};        % Pedersen conductivity, in S/m
    
    s2 = tmp{4};        % Hall conductivity, in S/m 
                        % (1e-12 if the value is less than 1e12)

    position = [tl(1:2)]; % Geog. Location ([Lat Lon], in degrees)
	time = datenum(tl(3),tl(4),tl(5),tl(6),0,0); % Matlab serial date, in UT
    
    s = struct('s0', s0, 's1', s1, 's2', s2);
    
    output = struct('height', height, 'time', time, 's', s, ...
        'location', position);
    