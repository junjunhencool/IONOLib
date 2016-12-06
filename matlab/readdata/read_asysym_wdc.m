%
% output = read_asysym_wdc([], []);
%
function output = read_asysym_wdc(filename, verbose)

    if isempty(filename), filename = ...
            '/home/rilma/work/database/wdc/kyoto/asysym/asysym_200411.txt';
    end
    
    if isempty(verbose), verbose = 1; end;
    
    for i = 1 : numel(filename(:,1))
        
        tmp_filename = filename(i, :); fileinfo = dir(tmp_filename);
        tmp_fname = [tmp_filename(1:numel(tmp_filename) - ...
            numel(fileinfo.name)) fileinfo(1).name];

        fid = fopen(tmp_fname, 'rt');
        
           if (verbose == 1), disp(['Reading: ' tmp_fname]); end;
           
           counter = 0; iseof = 0;
           tmp_time = []; tmp_h_sym = [];
           
           while(iseof~=(-1))
               
               iseof = fgets(fid); tmp_strline = iseof;

               tmp_comp = tmp_strline(19:19); 
               tmp_index = tmp_strline(22:24);
               
               tmp_hminvalues = ...
                  sscanf(tmp_strline(35:numel(tmp_strline)), '%6i');              
               
               comp_index = [tmp_comp '_' tmp_index];
               
               switch comp_index
                   case 'D_ASY'
                   case 'H_ASY'
                   case 'D_SYM'
                   case 'H_SYM'
                       if isempty(tmp_h_sym)
                           tmp_h_sym = tmp_hminvalues(1:60);
                       else
                           tmp_h_sym = cat(2, tmp_h_sym, ...
                               tmp_hminvalues(1:60)); 
                       end      
                       
%                       tmp_ymd = sscanf(tmp_strline(13:18), '%2i');
                       tmp_ymd = str2num([tmp_strline(13:14); ...
                           tmp_strline(15:16); tmp_strline(17:18)]);
%                       tmp_comp = tmp_strline(19:19);
                       tmp_hh = str2num(tmp_strline(20:21));
                       tmp_year = tmp_ymd(1) + 1900 + ...
                           100 * (tmp_ymd(1) < 70);
                       tmptime = datenum(tmp_year, tmp_ymd(2), ...
                           tmp_ymd(3), tmp_hh, [0:59], 0);
                       
                       if isempty(tmp_time)
                           tmp_time = tmptime; 
                       else
                           tmp_time = cat(1, tmp_time, tmptime);
                       end
                       
               end
               
               if (ftell(fid) >= fileinfo.bytes), iseof = -1; end;
               
               counter = counter + 1;
              
           end
           
        fclose(fid);
        
        if i == 1
            time = tmp_time; h_sym = tmp_h_sym;
        else
            time = cat(1, time, tmp_time); h_sym = cat(2, h_sym, tmp_h_sym);
        end
        tmp_time = []; tmp_h_sym = [];
        
    end
    
    [nx, ny] = size(time); time = reshape(time', ny*24, nx/24);
    h_sym = permute(h_sym, [2 1]); h_sym = reshape(h_sym', ny*24, nx/24);
    
    output = struct('time', time, 'h_sym', h_sym);
              