
function output = read_mlh_data(filename, verbose)

    if isempty(filename)
        filename = 'C:\Users\rilma\work\projects\nov2004_superstorm\mlh\mlh041109g.txt';
    end
    
    if isempty(verbose), disp(['Reading: ' filename]); end;
    
    fid = fopen(filename);
    
        for i = 1 : 23
            iseof = fgets(fid);
            if i == 6
               tmp_tdate = get_time_str(iseof);
            else if i == 7
                    tmp_tdate = [tmp_tdate get_time_str(iseof)];
                end
            end
        end
        
        tmp_data = textscan(fid, '%f %f %f %f %f %f %f %f %f %f ', 'CollectOutput', 1);
        
    fclose(fid);
        
    junk = tmp_data{:, :}; [tmp_nrow, npar] = size(junk);

    ind_noval = find(junk == 9999.00);
    if ~isempty(ind_noval), junk(ind_noval) = NaN; end;    
    
    tmp_row_ind = 2:1:tmp_nrow; tmp_row_ind = [tmp_row_ind 1];
 
%    
% ind(0) contains the number of altitudes
%
    ind = find((junk(:, 1) - junk(tmp_row_ind, 1)) ~= 0);
    
    tmp_junk = reshape(junk, ind(1), tmp_nrow / ind(1), npar);    
        
    output = struct('altitude', tmp_junk(:, 1, 2), ...
        'edensity', transpose(tmp_junk(:, :, 3)), ...
        'los_idrift', transpose(tmp_junk(:,:,9)), ... % Line-of-sight ion drift
        'err_los_idrift',transpose(tmp_junk(:,:,10)), ... % ion drift error
        'time', floor(tmp_tdate(1)) + transpose(tmp_junk(1,:,1)) / 24);
           
function output = get_time_str(strline)

    colon_pos = strfind(strline, ':');
    month = str2num(strline(colon_pos + (2:3))); dom = str2num(strline(colon_pos + (5:6)));
    year = str2num(strline(colon_pos + (8:11))); hour = str2num(strline(colon_pos + (14:15)));
    minute = str2num(strline(colon_pos + (16:17)));
    
    output = datenum(year,month,dom,hour,minute,0);
    