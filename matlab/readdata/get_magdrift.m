
function output = get_magdrift(dpath,trange)

    myDPath = '/media/sda5/database/jro/vdriftsmag/peruvian/';
    try if isempty(dpath), dpath = myDPath; end; catch dpath = myDPath; end;
    
    myTRange = datenum(2004,11,(9:13)');
    try if isempty(trange), trange = myTRange; end; catch trange = myTRange; end;
    
    [yy,mm,dd] = datevec(myTRange);
    doy = myTRange - datenum(yy,1,1,0,0,0) + 1.0;
    
    for i = 1 : numel(myTRange)
        filename = ['JP' num2str(doy(i),'%03i') '.' num2str(yy(i),'%04i') '.dat'];
        tmp = read_magdrift([dpath filename]);
        TValues = myTRange(i) + tmp{1,1}/24.0;
        if i == 1
            time = TValues; vdrift = tmp{1,2};
        else
            time = cat(1,time,TValues); vdrift = cat(1,vdrift,tmp{1,2});
        end
    end
    
    output = struct('time',time,'vdrift',vdrift);
    
function output = read_magdrift(filename)

    fid = fopen(filename, 'r');
        format = '%f %f %f %f %f';
        tmp = textscan(fid,format,'HeaderLines',0);
    fclose(fid);
    
    output = tmp;
    