
function [time, spc] = read_jro_drifts_specs(filename, header)

    fid = fopen(filename, 'r', 'ieee-le');
    
        if fid == -1
            time = []; data = [];
            return;
        end
    
        time = 0; tmp_data = 0;
    
        if length(header) == 0
            header = struct('num_prof',128,'num_hei',60,'dummy',4,'num_beams',1);
        end

        [month, dom] = get_date(header.year, header.doy);
        slash_pos = strfind(filename,'/');
        fname = filename(slash_pos(numel(slash_pos))+1:numel(filename));
        
        [interval_number, dummy] = strtok(fname, '.');
        [tmp, dummy] = strtok(fname, 'm');
        avg_time = 10.0 * (str2num(tmp) - str2num(interval_number));
        hour = str2num(interval_number) * avg_time * 60.0 / 3600.0;
        minute = (hour - floor(hour)) * 60.0;
        second = (minute - floor(minute)) * 60.0;    
        time = datenum(header.year,month,dom,floor(hour),floor(minute),second);

        tmp_data = fread(fid, 2 * header.num_prof * header.num_hei * ...
            header.num_chan * header.num_beams , 'float32');
  
        [ni, nj] = size(tmp_data); real_index = [1:2:ni]; imag_index = [2:2:ni];

        real_data = reshape(tmp_data(real_index,:), header.num_prof, ...
            header.num_hei, header.num_chan, header.dummy/2);
        
%        for i = 2 : header.num_prof
%            real_data(i,:,:,:) = real_data(i,:,:,:)./ real_data(1,:,:,:);
%        end
        
        imag_data = reshape(tmp_data(imag_index,:), header.num_prof, ...
            header.num_hei, header.num_chan, header.dummy/2);  
  
        spc = repmat(real_data(:,:,[1 2],:),[1 1 1 1]);
  
     fclose(fid);
 