%function [time, data, real_data, imag_data] = read_min_specs(filename, header)
function [time, data] = read_min_specs(filename, header)

 fid = fopen(filename, 'r', 'ieee-le');
  if fid == -1
      time = [];
      data = [];
      return;
  end
  time = 0; tmp_data = 0;
  if length(header) == 0
      header = struct('num_prof',128,'num_hei',60,'dummy',4,'num_beams',1);
  end

  [month, dom] = get_date(header.year, header.doy);
  slash_pos = strfind(filename,'/');
  fname = filename(slash_pos(numel(slash_pos))+1:numel(filename));
  [token, rem] = strtok(fname, '.');
  hour = str2num(token) * 5 * 60.0 / 3600.0;
  minute = (hour - floor(hour)) * 60.0;
  second = (minute - floor(minute)) * 60.0;
%  time = [num2str(header.year,'%04d') '-' num2str(month,'%02d') '-' num2str(dom,'%02d') ' ' ...
%      num2str(floor(hour),'%02d') ':' num2str(floor(minute),'%02d') ':' num2str(floor(second),'%02d')];
  time = datenum(header.year,month,dom,hour,minute,second);
  tmp_data = fread(fid, 2 * header.num_prof * header.num_hei * header.dummy * header.num_beams , 'float32');
  [ni, nj] = size(tmp_data); real_index = [1:2:ni]; imag_index = [2:2:ni];
  real_data = reshape(tmp_data(real_index,:), header.num_prof, header.num_hei, header.dummy, header.num_beams);
  imag_data = reshape(tmp_data(imag_index,:), header.num_prof, header.num_hei, header.dummy, header.num_beams);
  my_zeros = zeros(header.num_prof, 20, header.num_hei, header.num_beams);
  data = complex(my_zeros, my_zeros);
  data(:,[1 2],:,:) = permute(complex(real_data(:,:,[1 2],:), 0), [1,3,2,4]);
%  data(:,[3 4],:,:) = permute(complex(real_data(:,:,[5 6],:), 0), [1,3,2,4]);  
  data(:,[11 12],:,:) = permute(complex(imag_data(:,:,[1 2],:),0),[1,3,2,4]);
  data(:,5,:,:) = permute(complex(real_data(:,:,3,:), imag_data(:,:,3,:)),[1,3,2,4]);
  data(:,15,:,:) = permute(complex(real_data(:,:,4,:), imag_data(:,:,4,:)),[1,3,2,4]);
  
 fclose(fid);
 