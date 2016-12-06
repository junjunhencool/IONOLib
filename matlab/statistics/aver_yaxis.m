    
function output = aver_yaxis(values, err_values)

    [nx, ny] = size(values); avg_values = repmat(NaN, nx, 1);
    avg_err_values = avg_values;
    
    for i = 1 : nx
        
        ind_val_nonan = find(isnan(values(i, :)) == 0);
        ind_err_nonan = find(isnan(err_values(i, :)) == 0);
        
        if numel(ind_val_nonan) > numel(ind_err_nonan), ind_nonan = ind_err_nonan; ...
        else ind_nonan = ind_val_nonan; end;
                
        if ~isempty(ind_nonan)
            
            avg_values(i, 1) = sum(values(i,ind_nonan) ./ err_values(i,ind_nonan) .^ 2) ./ ...
                sum(1 ./ err_values(i,ind_nonan) .^ 2);                        
            
            avg_err_values(i, 1) = 1.0 ./ sum(1.0 ./ err_values(i,ind_nonan) .^ 2);
            
        end
        
        if isempty(find(isfinite(err_values(i, ind_nonan)), 1))
            avg_values(i, 1) = sum(values(i, ind_val_nonan)) / numel(ind_val_nonan);
        end
        
    end 
    
    output = struct('values', avg_values, 'err_values', avg_err_values);
