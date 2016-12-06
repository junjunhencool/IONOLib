
function [out_xvals, out_yvals, out_zvals] = fillgaps(in_xvals, in_yvals, in_zvals)

    nx = numel(in_xvals); ind_shifted = [2:nx 1];    
    
    xstep = mode(abs(in_xvals - in_xvals(ind_shifted)));
    xrange = [min(in_xvals) max(in_xvals)];    
    
    out_xvals = (xrange(1) : xstep : xrange(2))';
    nx_out = numel(out_xvals);
    
    ny = numel(in_yvals);
    
    out_zvals = repmat(NaN, nx_out, ny);   
    
    if ~isempty(in_zvals), out_yvals = in_yvals; else ...
        out_yvals = repmat(NaN, ny, 1); end;

    for i = 1 : nx
        ind = find(abs(out_xvals - in_xvals(i)) < 0.5*xstep);
        if ~isempty(ind)
            if ~isempty(in_zvals)
                out_zvals(ind, :) = in_zvals(i, :);
            else
                out_yvals(ind) = in_yvals(i);                
            end
        end
    end

    