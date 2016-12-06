
function output = load_ace_magswe_hdf(hdf_filenames)

    for i = 1 : numel(hdf_filenames(:, 1))
        
        tmp_output = read_ace_magswe_hdf(hdf_filenames(i,:));
        
        if i == 1, output = tmp_output;
        else
            fn1l = fieldnames(tmp_output);
            for j = 1 : numel(fn1l)
                if j < 3
                    fn2l = fieldnames(getfield(tmp_output, fn1l{j,1}));
                    for k = 1 : numel(fn2l)
                        tmp_out_fvalue = getfield(getfield(output, fn1l{j,1}), fn2l{k,1});
                        tmp_fvalue = getfield(getfield(tmp_output, fn1l{j,1}), fn2l{k,1});
                        new_fvalue = cat(2, tmp_out_fvalue, tmp_fvalue);
                        if k == 1, tmp_1l_output = struct(fn2l{k,1}, new_fvalue);
                        else tmp_1l_output = setfield(tmp_1l_output, fn2l{k,1}, new_fvalue);
                        end
                    end
                else
                    tmp_out_fvalue = getfield(output, fn1l{j,1});
                    tmp_fvalue = getfield(tmp_output, fn1l{j,1});
                    tmp_1l_output = cat(2, tmp_out_fvalue, tmp_fvalue);
                end
                output = setfield(output, fn1l{j,1}, tmp_1l_output);
            end
        end
    end
    input = output;
    output = ace_magswe_quality(input);
        
    
function output = read_ace_magswe_hdf(hdf_filename)
%
%   READ_ACE_MAGSWE_HDF Reads 
%

    info = hdfinfo(hdf_filename);
    
    disp(['Reading: ' hdf_filename]);
        
    for i = 1 : numel(info.Vgroup)
        
        out_field_name = info.Vgroup(1,i).Name(4:numel(info.Vgroup(1,i).Name));
        group_name = ['/' info.Vgroup(1,i).Name '/' out_field_name];
              
        num_records = info.Vgroup(1,i).Vdata.NumRecords;
        
        for j = 1 : numel(info.Vgroup(1,i).Vdata.Fields)
            
            field_name = info.Vgroup(1,i).Vdata.Fields(j).Name;
            
            tmpdata = hdfread(hdf_filename, group_name, 'Fields', field_name, ...
                'FirstRecord', 1, 'NumRecords', num_records);
            
            tmpdata = cell2mat(tmpdata);
            
            if j == 1, tmp_output = struct(field_name, tmpdata); else ...
                    tmp_output = setfield(tmp_output, field_name, tmpdata); end;                        
            
        end
        
        if i == 1, output = struct(out_field_name, tmp_output); else ...
                output = setfield(output, out_field_name, tmp_output); end;
                
    end
    
    year = output.MAGSWE_data_64sec.year; doy = output.MAGSWE_data_64sec.day;
    hour = output.MAGSWE_data_64sec.hr; minute = output.MAGSWE_data_64sec.min;
    second = output.MAGSWE_data_64sec.sec;
        
    fd = double(hour*3600 + minute*60 + int32(second))/(24*3600);
    time = datenum(double(year),1,1,0,0,0) + double(doy - 1) + fd;
    
    output = setfield(output, 'time', time);
    
function output = ace_magswe_quality(input)
%
%   ACE_MAGSWE_QUALITY Replaces bad quality values (-9999.9) with NaN values 
%   (undefined number) in all the fields.
%
%   input: structure type variable whose fields are intended to be replaced
%   with NaN values whenever a -9999.9 does occurs.
%
%   output: structure type variable containing the same fields as input
%   variable but upgraded with NaN values whenever a -9999.9 occurred.
%
%   IMPORTANT NOTICE: This function is intended to be utilized in
%   conjunction with LOAD_ACE_MAGSWE_HDF function, so the author can not
%   guarantee its use for a different goal, but you can modify it for your own
%   needs.
%
%   Created on: February 15, 2008 by Ronald Ilma
%

    fn1l = fieldnames(input);
    
    for i = 1 : numel(fn1l)
        
        if i < 3
            
            fn2l = fieldnames(getfield(input, fn1l{i, 1}));
            for j = 1 : numel(fn2l)
                
                fvalues = getfield(getfield(input, fn1l{i, 1}), fn2l{j, 1});
                ind_novalid = find(fvalues <= -9999.9);
                
                if ~isempty(ind_novalid), fvalues(ind_novalid) = NaN; end;
                
                if j == 1, slstruct = struct(fn2l{j,1}, fvalues);
                else slstruct = setfield(slstruct, fn2l{j,1}, fvalues); end;
                
            end
            
            if i == 1, output = struct(fn1l{i,1}, slstruct); else ...
                    output = setfield(output, fn1l{i,1}, slstruct); end;
            
        else output = setfield(output, fn1l{i,1}, getfield(input, fn1l{i,1})); end;
        
    end
