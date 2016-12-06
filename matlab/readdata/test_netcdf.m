function test_netcdf

    if isunix
        root_dir = '/media/sda5';
    else
        root_dir = 'D:';
    end

    dpath = [root_dir '/Users/rilma/work/database/jro/isrperp/procdata/'];
    
    fname = 'r2008283.ncdf';
    
    tmp = read_ncdf([dpath fname]);
    

function output = read_ncdf(filename)

    disp(['Reading: ' filename]);
            
    dinfo = netcdf(filename);    
    
    for i = 1 : numel(dinfo.VarArray)
        
        fn = dinfo.VarArray(i).Str;
        fd = dinfo.VarArray(i).Data;
        
        if i == 1, data = struct(fn, fd); else ...
                data = setfield(data, fn, fd); end;
        
    end
    
    for i = 1 : numel(dinfo.DimArray)
        
        fn = dinfo.DimArray(i).Str;
        fd = dinfo.DimArray(i).Dim;
        
        if i == 1, dimdata = struct(fn, fd); else ...
                dimdata = setfield(dimdata, fn, fd); end;
        
    end
    
    output = struct('data', data, 'dim', dimdata);