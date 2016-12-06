
function [xvalues, yvalues] = selvalues(xvalues, yvalues, range)

    ind_tpd = find(xvalues >= range(1) & xvalues <= range(2));
    
    if ~isempty(ind_tpd)        
        xvalues = xvalues(ind_tpd); yvalues = yvalues(ind_tpd);
    end
    