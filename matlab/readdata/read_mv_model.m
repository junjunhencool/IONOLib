function output = read_mv_model(filename, verbose)

    if verbose == 1, disp(['Reading: ' filename]); end;
    fid = fopen(filename, 'r');
        for i = 1 : 3, junk = fgets(fid); end; time = datenum(junk);
        tmp = textscan(fid, '%f %f', 'HeaderLines', 3);
    fclose(fid);
        
    output = struct('edensity',tmp{1,2}, 'height',tmp{1,1}, 'time',time);
    