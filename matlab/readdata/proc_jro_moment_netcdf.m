%
% ch[i j ...]:
%      1 : A
%      2 : B
%      3 : C
%      4 : D
%
% vars[i j ...]:
%      1 : Radial velocity; 
%      2 : 1/2 spectral width
%      3 : Signal-to-Noise ratio
%      4 : Noise level
%
function proc_jro_momment_netcdf

    if isunix
        root_dir = '/media/sda5';
    else
        root_dir = 'D:';
    end

    trange = datenum(2008,10,9,[17 23],[0 0],[0 0]);
    vars = [3];
    ch = [1 3];
    
    dpath = [root_dir '/Users/rilma/work/database/jro/isrperp/procdata/'];
    
    % Reading the netCDF data file
    %
    
    dt = datevec(trange);
    doy = datenum(dt(:,1),dt(:,2),dt(:,3),0,0,0) - ...
        datenum(dt(:,1),1,1,0,0,0) + 1;
    
%    fname = ['r' num2str(dt(1,1),'%04i') num2str(doy(1,1),'%03i') '.ncdf'];

    fname = ['r' num2str(dt(1,1),'%04i') num2str(doy(1,1),'%03i') '.mat'];
    
%    jro = read_ncdf([dpath fname]);
    
    if 1 == 0
        
        jro1 = struct('data',struct('Channel',jro.data.Channel, ...
            'Height',jro.data.Height,'Time',jro.data.Time, ...
            'SNR',jro.data.SNR), ...
            'dim', jro.dim);
        
        save([dpath 'r2008283.mat'], 'jro1');
        
    end
    
    load([dpath fname]); jro = jro1;
    
    for j = 1 : numel(vars)
        for i = 1 : numel(ch)
        end
    end
    
    
    disp('Stop!');