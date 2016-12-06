
 function output = read_jro_isrperp_proc(filename)
     nlHeader = 6; 
     aTime = []; aProf = [];
     [ndays, dummy] = size(filename);
     for i = 1 : ndays
         fileinfo = dir(filename(i,:));
         counter = 0; iseof = 0;
         if isempty(fileinfo)
             disp(['This file could not be found: ' filename(i,:)]);             
         else
             fid = fopen(filename(i,:),'rt');
                disp(['Reading: ' filename(i,:)]);
                for j = 1 : nlHeader
                    currHLine = fgets(fid); header(j) = {currHLine};
                    if j == 2, [yy,mm,dd,hh,mi,ss] = ...
                            datevec(datenum(currHLine(1:11), 'dd-mmm-yyyy')); end;
                    if j == 3, str_vars_type = ...
                            strtrim(currHLine(4:length(currHLine))); end;
                    if j == 5
                        strhvec = deblank(currHLine(10:length(currHLine)));
                        height = str2num(reshape(strhvec,9,length(strhvec)/9)');
                        nhei = numel(height);
                    end
                end

                while(iseof~=(-1))
                    strLine = fgets(fid); dLine = sscanf(strLine, '%f');
                    currTime = datenum(yy,mm,dd,dLine(1),dLine(2),dLine(3));
                    currProf = dLine(4:numel(dLine));
                    if counter == 0
                        time = currTime; prof = currProf;
                    else
                        time = cat(2, time, currTime);
                        prof = cat(2, prof, currProf);
                    end
                    if (ftell(fid) >= fileinfo.bytes), iseof = -1; end;
                    counter = counter + 1;
                end
             fclose(fid);
             if i == 1
                 aTime = time; aProf = prof;
             else
                 aTime = cat(2, aTime, time);
                 aProf = cat(2, aProf, prof);
             end
         end
     end
     
 output = struct('height', height, 'prof', aProf', 'time', aTime', ...
     'varname', str_vars_type);
     