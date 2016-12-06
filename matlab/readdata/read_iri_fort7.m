function output = read_iri_fort7(filename)
    fid = fopen(filename, 'r');
        data_format = repmat('%f', 1, 15);
        tmp = textscan(fid, data_format, 'HeaderLines', 29);
    fclose(fid);
    output = struct('height', tmp{1,1}, 'edensity', tmp{1,2}, ...
        'Oplus_fraction', tmp{1,7}, 'Nplus_fraction', tmp{1,8}, ...
        'Hplus_fraction', tmp{1,9}, 'Heplus_fraction', tmp{1,10}, ...
        'O2plus_fraction', tmp{1,11}, 'NOplus_fraction', tmp{1,12}, ...
        'Clusters_fraction', tmp{1,13});