
function save_figure(handle, type, resolution, orientation, filename)

    if type > 1, set(handle, 'PaperPositionMode', 'auto'); end;
    
    try if isempty(orientation), orientation = 'portrait'; end; 
    catch orientation = 'portrait'; end;
    
    orient(handle, orientation);
    
    resolution_op = ['-r' num2str(resolution)];
    
    switch type
        
        case 1
        
        case 5
            print(handle, '-dpsc', resolution_op, [filename '.ps']);

        case 6
            print(handle, '-depsc', [filename '.eps']);

        case 12
            print(handle, '-djpeg', [filename '.jpg']);
            
        case 15
            print(handle, '-dpng', resolution_op, [filename '.png']);
            
        otherwise
            
    end
    