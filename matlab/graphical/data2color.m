
function outdata = data2color(indata, drange, crange)

    dvalues = indata;
    
    bottom_color = min(crange); top_color = max(crange);
    
    dmin_val = min(drange); dmax_val = max(drange);
    
    cvalues = bottom_color + round((top_color - bottom_color) * ...
    (dvalues - dmin_val) / (dmax_val - dmin_val)) + 1;
 
    is_gtmax = find(dvalues >= dmax_val);
    if ~isempty(is_gtmax), cvalues(is_gtmax) = top_color; end;            
               
    is_gtmin = find(dvalues <= dmin_val);
    if ~isempty(is_gtmin), cvalues(is_gtmin) = bottom_color; end;
         
%    is_nan = find(isnan(dvalues) == 1);
%    if ~isempty(is_nan), cvalues(is_nan) = 113; end;            
      
    outdata = cvalues;
