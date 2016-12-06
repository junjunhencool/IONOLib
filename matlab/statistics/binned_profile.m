
function output = binned_profile(prof_values, yaxis_values, bin_info)

    bin_values = bin_info(1) - bin_info(3) / 2 : bin_info(3) : ...
        bin_info(2) + bin_info(3) / 2;
    
    num_intervals = length(bin_values) - 1;
    tmp_prof_values = repmat(num_intervals, 1) .* NaN;
    
    for i = 1 : num_intervals
%        disp(['From: ' num2str(bin_values(i), '%5.2f') ' to ' ...
%            num2str(bin_values(i + 1), '%5.2f') ' km']);
        ind = find(yaxis_values >= bin_values(i) & ...
            yaxis_values < bin_values(i + 1));
        if ~isempty(ind)
            tmp_prof_values(i) = median(prof_values(ind));
        else tmp_prof_values(i) = NaN; 
        end
    end

    output = struct('prof_values', tmp_prof_values, ...
        'yaxis_values', bin_values(1:num_intervals) + bin_info(3) / 2);
    
