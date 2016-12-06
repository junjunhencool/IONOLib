
function output = read_iri2007_data(filename, verbose)

    myDPath = '/media/sda5/Users/rilma/work/database/models/iri2007/';
    myFileName = [myDPath 'iri_20080709_01_pfisr.txt'];
    try if isempty(filename), filename = myFileName; end; ...
    catch filename = myFileName; end;

    try if isempty(vernbose), verbose = 1; end; catch verbose = 1; end;    

    fileinfo = dir(filename);

    fid = fopen(filename, 'r');
    
        counter = 0; iseof = 0;
        
        while (iseof ~= (-1))
            
            if counter == 0
                
                for i = 1 : 3, iseof = fgets(fid); end;
                
            else
                
                iseof = fgets(fid); tmpStrLine = iseof;
                ind = strfind(tmpStrLine,',');
                for ii = 1 : numel(ind), tmpStrLine(ind(ii):(ind(ii)+1)) = ' '; end;
                infovalues = sscanf(tmpStrLine, '%f');
                
                if ~isempty(infovalues)
                    
                    numhei = (infovalues(6) - infovalues(5))/infovalues(7) + 1;
                
                    for ii = 1 : numhei
                        iseof = fgets(fid); tmpStrLine = iseof;
                        tmp = sscanf(tmpStrLine,'%f');
                        if ii == 1
                            tmpEDens = tmp(2,1); tmpTi = tmp(4,1); tmpTe = tmp(5,1);
                            tmpHeight = tmp(1,1);
                        else
                            tmpHeight = cat(2,tmpHeight,tmp(1,1));
                            tmpEDens = cat(2,tmpEDens,tmp(2,1));
                            tmpTi = cat(2,tmpTi,tmp(4,1));
                            tmpTe = cat(2,tmpTe,tmp(5,1));                        
                        end
                    end
                    tmpTime = datenum(infovalues(1),infovalues(2), ...
                        infovalues(3)) + infovalues(4)/24.0;

                    if counter == 1
                        edens = tmpEDens; itemp = tmpTi; etemp = tmpTe;
                        time = tmpTime;
                    else
                        edens = cat(1, edens, tmpEDens);
                        itemp = cat(1, itemp, tmpTi);
                        etemp = cat(1, etemp, tmpTe);
                        time = cat(1, time, tmpTime);
                    end

                end
                
            end
            
            if (ftell(fid) >= fileinfo.bytes), iseof = -1; end;
            counter = counter + 1;
            
        end
        
        output = struct('time',time,'height',tmpHeight', ...
            'edensity',edens, ...
            'etemperature',etemp,'itemperature',itemp);
        
    fclose(fid);
