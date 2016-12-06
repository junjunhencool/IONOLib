
function plot_polynomial(x,p)

%    close all;
    
    myP = [0.0 0.0 1.0 1.0];
    try if isempty(p), p = myP; end; catch p = myP; end;

    myX = -3.5:0.1:3.5;
    try if isempty(x), x = myX; end; catch x = myX; end;
    
    y = polyval(p, x);

    myXLim = [min(x) max(x)];
    myYLim = [0.95*min(y) 1.05*max(y)];
    
    hf = figure(20); %clf(hf,'reset');
%    set(hf);
%    plot(x,y);
%    set(gca,'XLim',myXLim,'YLim',myYLim);

    plot(y,x,'Color','r')
%    line(-y,-x,'Color','b')
    set(gca,'XLim',myYLim,'YLim',myXLim);
    
    line(x,x,'Color','k','LineStyle','.')
    grid on;
