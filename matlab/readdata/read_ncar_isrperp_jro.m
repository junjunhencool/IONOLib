%
% data = read_ncar_isrperp_jro([],[]);
% [data, mdata] = read_ncar_isrperp_jro([],[]);
%
function [output, data] = read_ncar_isrperp_jro(filename, verbose)
%
%     READ_NCAR_DRIFTS Read JRO drifts from ISR perp. to B experiments in 
%     NCAR format
%

    if isempty(filename)
         filename = ...
             [repmat('/home/rilma/work/database/jro/isrperp/drifts/ncar/', ...
             3, 1),  ['jro_drifts2003315.txt'; 'jro_drifts2003316.txt'; 'jro_drifts2003317.txt']];
    end;
    
    if isempty(verbose), verbose = 1; end;

    time = []; data = []; junk_kods_value = [];
    
    for j = 1 : numel(filename(:,1))
        
        tmp_filename = filename(j, :);
    
        fileinfo = dir(tmp_filename);
    
        counter = 0; iseof = 0;
        
        if isempty(fileinfo)            
            if (verbose == 1), disp(['This file could not be found: ' tmp_filename]), end;
        else
            
        tmp_fname = [tmp_filename(1:numel(tmp_filename) - numel(fileinfo.name)) fileinfo(1).name];
        
        fid = fopen(tmp_fname, 'rt');
    
            if (verbose == 1), disp(['Reading: ' tmp_fname]), end;
    
%   Reading catalog
            catalog = sscanf(fgets(fid), '%f'); ltot = catalog(1);

%   Reading header
            for i = 1 : ltot - 1, dummy = fgets(fid); end      

            while (iseof~=(-1))
            
                for i = 1 : 4
                
                    iseof = fgets(fid); tmp_strline = iseof;
                    tmp_intline = sscanf(tmp_strline, '%f');
                
                    if (i == 1)
                    
                        nrow = tmp_intline(16);

% num_kodm = Number of paramaters? (verify with table 7 in cedarFormat.ps)
                        mpar = tmp_intline(15);
                    
                        tmp_year = [tmp_intline(5) tmp_intline(9)];
                        tmp_month = fix([tmp_intline(6) tmp_intline(10)] ./ 100);
                        tmp_dom = mod([tmp_intline(6) tmp_intline(10)], 100);
                        tmp_hour = fix([tmp_intline(7) tmp_intline(11)] ./ 100);
                        tmp_minute = mod([tmp_intline(7) tmp_intline(11)], 100);
                        tmp_second = fix([tmp_intline(8) tmp_intline(12)] ./ 100);
                        tmp_time = mean(datenum(tmp_year, tmp_month, tmp_dom, tmp_hour, tmp_minute, tmp_second));
                
                    end
                    
                    if i == 2, kods_code = tmp_intline; end;
                    
                    if i == 3, kods_value = tmp_intline; end;
                    
                    if i == 4, kodm_code = tmp_intline; end;
        
                end
            
                tmp = fscanf(fid, [repmat('%6f', 1, mpar) '\n'], [mpar nrow]);
            
                if (counter == 0), mdata = tmp; else mdata = cat(3, mdata, tmp); end;
                if (counter == 0), mtime = tmp_time; else mtime = cat(1, mtime, tmp_time); end;
                
                if counter == 0, tmp_kods_value = kods_value; else ...
                        tmp_kods_value = cat(2,tmp_kods_value, kods_value); end;
                
                if (ftell(fid) >= fileinfo.bytes), iseof = -1; end;
            
                counter = counter + 1;
            
            end
        
        fclose(fid);
    
%         if (j == 1), time = mtime; else time = cat(1, time, mtime); end;
%         if (j == 1), data = mdata; else data = cat(3, data, mdata); end;
%         if j == 1, junk_kods_value = tmp_kods_value; else ...
%                 junk_kods_value = cat(2, junk_kods_value, tmp_kods_value); end;

        if isempty(time), time = mtime; else time = cat(1, time, mtime); end;
        if isempty(data), data = mdata; else data = cat(3, data, mdata); end;
        if isempty(junk_kods_value), junk_kods_value = tmp_kods_value; else ...
                junk_kods_value = cat(2, junk_kods_value, tmp_kods_value); end;
        
        end
        
    end
 
    kods_value = junk_kods_value; %junk_kods_value = []; tmp_kods_value = [];
    data = permute(data, [3, 2, 1]); 
    
    ind_novalid = find(data == -32767);
    if ~isempty(ind_novalid), data(ind_novalid) = NaN; end;
    
    ind_novalid = find(kods_value == -32767);
    if ~isempty(ind_novalid), kods_value(ind_novalid) = NaN; end;
   
    
    kinst = catalog(3); kindat = catalog(4);
    
    [kodm_info] = ncar_info([]);

%
% Looking for electron density data
%
    ind_densvar = find(kodm_code == 510);    
        
    if ~isempty(ind_densvar)

%
% Upgrading ¨ncar_info¨ routine´s output variable with information from
% Abolute Power experiment
%
        
        if kindat == 1850 & numel(ind_densvar) == 2     % right KINDAT for Abs. Power exp. ?
            
            ind_densdat = find(kodm_info.code == 510);
            tmp_kodm_edens = struct('code', repmat(510, 2, 1), 'description', ...
                ['Electron density (absolute power)    '; ...
                 'Electron density (fitted to F-peak)  '], ...
                'factor', repmat(1.0E9, 1, 2), 'units', repmat('m-3', 2, 1), ...
                'mnemonic', ['ne_abspow'; 'ne_fitt  ']);            
           
            for k = 1 : numel(tmp_kodm_edens.code)
                if k == 1
                    kodm_info.description(ind_densdat(k), :) = tmp_kodm_edens.description(k, :);
                    kodm_info.mnemonic(ind_densdat(k), :) = tmp_kodm_edens.mnemonic(k, :);
                else
                    kodm_info.code = cat(2, kodm_info.code, tmp_kodm_edens.code(k, :));
                    kodm_info.description = cat(1, kodm_info.description, tmp_kodm_edens.description(k, :));
                    kodm_info.factor = cat(2, kodm_info.factor, tmp_kodm_edens.factor(:, k));
                    kodm_info.units = cat(1, kodm_info.units, tmp_kodm_edens.units(k, :));
                    kodm_info.mnemonic = cat(1, kodm_info.mnemonic, tmp_kodm_edens.mnemonic(k, :));
                end
            end
            
           ind_novalid0 = find(data == 0);
           if ~isempty(ind_novalid0), data(ind_novalid0) = NaN; end;           
                    
        end
        
    end

%
% Creting a output structure containing data from the NCAR file(s)
%
    for i = 1 : numel(kodm_code)
        
        ikodm = find(kodm_info.code == kodm_code(i));
        if kindat == 1850 & numel(ikodm) == 2     % right KINDAT for Abs. Power exp. ?
            if i == 2, ikodm = ikodm(1); else ikodm = ikodm(2); end;
        end
        field_name = strtrim(kodm_info.mnemonic(ikodm, :));
        
        if i == 1
            description = kodm_info.description(ikodm, :);
            units = kodm_info.units(ikodm, :);
%            struct_data = struct(field_name, data(:, :, ikodm) * kodm_info.factor(ikodm));            
            struct_data = struct(field_name, data(:, :, i) * kodm_info.factor(ikodm));
        else
            description = cat(1, description, kodm_info.description(ikodm, :));
            units = cat(1, units, kodm_info.units(ikodm, :));
%            struct_data = setfield(struct_data, field_name, data(:, :, ikodm) * kodm_info.factor(ikodm));
            struct_data = setfield(struct_data, field_name, data(:, :, i) * kodm_info.factor(ikodm));            
        end;
        
    end
    
    kods = [];

%    
%   JRO    
%
    if kinst == 10

%
%   Abs. Power measurements during DVD exp.
%
        if kindat == 1850     % right KINDAT for Abs. Power exp. ?
            
            struct_data.range = struct_data.range(1, :);
            
%
%   Upgrading output structure variable with some "kods" values 
%   (noise and normalization constants)
%
            kods_info = struct('code', [3113 3114 3119 3120], 'description', ...
                ['rx A Noise log10(N)                  '; ...
                 'rx B Noise log10(N)                  '; ...
                 'JRO absolute power factor            '; ...
                 'JRO ionosonde normalization constant '], ...
                'factor', cat(2, repmat(1.0E-3, 1, 2).*10, repmat(1.0, 1, 2)), ...
                'units', cat(1, repmat('lg ', 2, 1), repmat('   ', 2, 1)), ...
                'mnemonic', ['jrop13   '; 'jrop14   '; 'jrop19   '; 'jrop20   ']);
            
        end
%        
%   East-West Drifts (it is not the unique experiment)
%
        if kindat == 1910
            
            struct_data.gdalt = struct_data.gdalt(1, :);
            struct_data.range = struct_data.range(1, :); 

%
%   Upgrading output structure variable with some "kods" values (noise)
%
            kods_info = struct('code', [3113 3114 3115 3116], 'description', ...
                ['West rx A Noise lg(N)                '; ...
                 'West rx B Noise lg(N)                '; ...
                 'East rx C Noise lg(N)                '; ...
                 'East rx D Noise lg(N)                '], ...
                'factor', repmat(1.0E-3, 1, 4).*10, 'units', repmat('lg ', 4, 1), ...
                'mnemonic', ['jrop13   '; 'jrop14   '; 'jrop15   '; 'jrop16   ']);
                                                            
        end

        %   Upgrading output structure variable with some "kods" values
        %        
        
        try if isempty(kods_info), kods_info = []; end; catch kods_info = []; end;
        
        if ~isempty(kods_info)
            
            kods_data = []; nfields = numel(fieldnames(kods_info));
            for i = 1 : numel(kods_info.code)
                field_name = strtrim(kods_info.mnemonic(i, :));
                ind_kvd = find(kods_code == kods_info.code(i));
                if ~isempty(ind_kvd)
                    fvalue = kods_value(ind_kvd, :)' .* kods_info.factor(:, i);
                    if isempty(kods_data), kods_data = struct(field_name, fvalue); else ...
                            kods_data = setfield(kods_data, field_name, fvalue); end;
                end
            end
            
            kods = struct('data', kods_data, 'info', kods_info);
            
        else
            kods = [];
        end
        %

        
    end
    
    output = struct('data', struct_data, 'time', time,  'description', description, ...
        'kodm_code', kodm_code, 'kods', kods, 'kods_code', kods_code, 'kods_value', kods_value, ...
        'units', units, 'timezone', -5);
    