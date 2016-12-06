
function output = averts(data,trange,tinfo)

        [yy,mm,dd] = datevec(trange); 
        myTRange = datenum(yy,mm,dd,0,0,0);
        NDays = myTRange(2) - myTRange(1) + 1;

        NTBins = 1.0 / (tinfo(1) / (24*60));
        
        tinfo = tinfo .* (1.0/(60.0*24.0));

        data_value_matrix = repmat(NaN, NTBins, NDays);
        data_time_matrix = data_value_matrix;
        
        for j = 1 : NDays
            upTLimit = datenum(yy(1),mm(1),dd(1),23,59,59) + (j - 1);
            data_time_matrix(:, j) = ((myTRange(1) + (j - 1)) : tinfo(1) : upTLimit)' + tinfo(2);
            OneDayTRange = [(myTRange(1) + (j -1)) upTLimit];
            ind_data = find(data.time >= OneDayTRange(1) & data.time <= OneDayTRange(2));
            if ~isempty(ind_data)
                st_step = 0.5*(data_time_matrix(2, j) - data_time_matrix(1, j));
                for i = 1 : NTBins;
                    ind = find(abs(data.time(ind_data) - data_time_matrix(i, j)) < st_step);
                    if ~isempty(ind), data_value_matrix(i,j) = data.value(ind_data(ind)); end;                    
                end
            end            
        end
        
        [yy1,mm1,dd1,hh,mi,ss] = datevec(data_time_matrix(:,1));

        mean_data = repmat(NaN, NTBins, 1);
        
        for i = 1 : NTBins
            ind = find(isfinite(data_value_matrix(i,:)));
            if ~isempty(ind)
                mean_data(i) = sum(data_value_matrix(i,ind))/numel(ind);
            end
        end        
        
        output = struct('ValueMatrix',data_value_matrix, ...
            'TimeMatrix',data_time_matrix, ...
            'mean',mean_data,'hour',hh,'minute',mi,'second',ss);
        