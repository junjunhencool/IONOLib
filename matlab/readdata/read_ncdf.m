
function output = read_ncdf(filename)
%
% Read the content of a netNCDF file using th "netcdf.m" routine
%

    disp(['Reading: ' filename]);

% Reading the whole content of a netCDF data file
    dinfo = netcdf(filename);    
    
% Reading variables, storing in a structure data type    
%
    for i = 1 : numel(dinfo.VarArray)
        
        fn = dinfo.VarArray(i).Str;
        fd = dinfo.VarArray(i).Data;
        
        if i == 1, data = struct(fn, fd); else ...
                data = setfield(data, fn, fd); end;
        
    end

% Reading dimension values of variables, and storing in a structure data
% type
%
    for i = 1 : numel(dinfo.DimArray)
        
        fn = dinfo.DimArray(i).Str;
        fd = dinfo.DimArray(i).Dim;
        
        if i == 1, dimdata = struct(fn, fd); else ...
                dimdata = setfield(dimdata, fn, fd); end;
        
    end
    
    output = struct('data', data, 'dim', dimdata);
    