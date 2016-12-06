
function output = read_digisonde_data(tdate, dtype, dpath)

    if isempty(dpath), dpath = '/media/sda1/Users/rilma/work/database/digisonde/LongTerm/'; end;
    if isempty(tdate), tdate = datenum(2004,11,[9 13]); end;
    if isempty(dtype), dtype = 1; end;
    
    tmp_tdate = tdate;
    if numel(tdate) > 1, tmp_tdate = tmp_tdate(1) : 1 : tmp_tdate(2); end;
    ndays = numel(tmp_tdate);
 
    fext = ['.SAO';'.DVL';'.SKY'];
    
    for i = 1 : numel(dtype)
        
        fname = [repmat(dpath,ndays,1), datestr(tmp_tdate,'yyyy'), ...
            repmat([filesep 'JI91J_'],ndays,1),...
            datestr(tmp_tdate,'yyyy'), datestr(tmp_tdate,'mm'),...
            datestr(tmp_tdate,'dd'), repmat('(',ndays,1),...
            num2str(calc_doy(tmp_tdate)','%03i'), repmat(')',ndays,1),...
            repmat(fext(dtype(i),:),ndays,1)];
        
        switch dtype(i)
            case 1
                sao_data = load_sao_digisonde(fname, 1);
        end        
        
    end 
        
    output = struct('sao', sao_data);

    
function output = load_sao_digisonde(filename, verbose)

    if isempty(verbose), verbose = 1; end;

    [nfiles, dummy] = size(filename);
    
    tmp_output = []; tmp_data = []; nhtab = [];
    
    for i = 1 : nfiles
        
        counter = 0; iseof = 0;
        
        if verbose == 1, disp(['Reading: ' filename(i,:)]); end;
        
        fileinfo = dir(filename(i,:));
        
        if ~isempty(fileinfo)
            
        fid = fopen(filename(i,:),'r');
            
            while(iseof ~= (-1))
                data_block = read_blck_sao(fid);            
                if (ftell(fid) >= fileinfo.bytes), iseof = -1; end;
                npar_scaled = 49; curr_npar_scaled = numel(data_block.scaled);
                nadd_par = npar_scaled - curr_npar_scaled;
                if curr_npar_scaled < npar_scaled                    
                    data_block.scaled = cat(1, data_block.scaled, repmat(9999.0, nadd_par, 1));
                end
                nhnf = ['block_' num2str(counter + 1, '%03i')];
                if counter == 0
                    tmp_data = data_block;
                    nhtab = struct(nhnf, data_block.nhtab);
                else
                    tmp_data = struct('time', [tmp_data.time data_block.time], ...
                        'scaled', cat(2, tmp_data.scaled, data_block.scaled));
                    nhtab = setfield(nhtab, nhnf, data_block.nhtab);
                end
                
                counter = counter + 1;
            end
            
        fclose(fid);
        
        end
        
        if isempty(tmp_output)
            if ~isempty(tmp_data), tmp_output = tmp_data; end;
            if ~isempty(nhtab), tmp_nhdata = nhtab; end;
        else
            tmp_output = struct('time', [tmp_output.time tmp_data.time], ...
                        'scaled', cat(2, tmp_output.scaled, tmp_data.scaled));

            curr_nblocks = numel(fieldnames(tmp_nhdata));
            for j = 1 : numel(fieldnames(nhtab))
                old_nhnf =  ['block_' num2str(j, '%03i')];
                curr_counter = j + curr_nblocks;
                curr_nhnf = ['block_' num2str(curr_counter, '%03i')];
                tmp = getfield(nhtab, old_nhnf);
                tmp_nhdata = setfield(tmp_nhdata, curr_nhnf, tmp);
            end
            
        end
        
    end

    ind_nan = find(isnan(tmp_output.scaled),1);
    if ~isempty(ind_nan), tmp_output.scaled(ind_nan) = NaN; end;
    
    scaled = struct('foF2', tmp_output.scaled(1, :), ...
        'TEC', tmp_output.scaled(39, :));

    hbins = 50.0 : 5.0 : 1100.0;    
    fn = fieldnames(tmp_nhdata);
    
    critfreq = repmat(NaN, numel(fn),numel(hbins));
    
    for j = 1 : numel(fn)
        tmp = getfield(tmp_nhdata, cell2mat(fn(j)));
        ind = find(hbins >= min(tmp.height) & hbins <= max(tmp.height));
        if ~isempty(ind)
            ish = repmat(0,numel(ind),1); isv = [];
            [hval, hind] = unique(tmp.height); dval = tmp.critfreq(hind);            
            for k = 1 : numel(hval)
                ind2 = find(hbins(ind) == hval(k));
                if ~isempty(ind2)
                    ish(ind2) = 1; 
                    if isempty(isv), isv = dval(k); ...
                    else isv = cat(1,isv,dval(k)); end;
                end
            end
            
            if ~(numel(find(isfinite(dval)))== 0)
                
                ind3 = find(ish == 0);
                critfreq(j, ind(ind3)) = spline(hval, dval, hbins(ind(ind3)));
            
                ind4 = find(ish == 1);            
                critfreq(j, ind(ind4)) = isv;
                
            end
            
        end
    end    
    
    output = struct('time', tmp_output.time, ...
        'scaled', scaled, 'nh',struct('height',hbins','freq',critfreq));
   
    
function output = read_blck_sao(fid)

    for i = 1 : 2
        
        tmp_idfi = str2num(reshape(fgetl(fid), 3, 40)');
        
        if i == 1, idfi = tmp_idfi; else ...
                idfi = cat(1, idfi, tmp_idfi); end;
        
    end
    
    if idfi(1) > 0 & idfi(1) < 17
        
        if idfi(80) >= 2

        end
        
        %...Geophysical constants -- Code 1        
        if idfi(1) > 0, gconst = str2num(reshape(fgetl(fid), 7, idfi(1))'); end;
        
        %...system description -- Code 2
        if idfi(2) > 0, sysdes = fgetl(fid); end;        
        if idfi(2) == 2, opmsg = fgetl(fid); end;
        
        %...ionogram sounding settings (preface) -- Code 3
        if idfi(3) > 0, opmsg = fgetl(fid); end;
        
        %...scaled ionogram parameters
        if idfi(4) > 0, scaled = read_one_group(fid, idfi(4), 15, 8); end;

        %...ARTIST analysis flags
        if idfi(5) > 0, iaf = read_one_group(fid, idfi(5), 60, 2); end;
        
        %...Doppler translation table
        if idfi(6) > 0, dtt = read_one_group(fid, idfi(6), 16, 7); end;
        
        %...O-trace F2 points
        
        %...virtual height
        if idfi(7) > 0            
            if idfi(80) >= 2    % SAO V4.0
                otf = read_one_group(fid, idfi(7), 15, 8);
            else    % SAO V3 and lower
            end
        end
        
        %...true height
        if idfi(8) > 0
            if idfi(80) >= 2    % SAO V4.0
                othf = read_one_group(fid, idfi(8), 15, 8);
            else    % SAO V3 and lower
            end
        end
        
        %...amplitudes
        if idfi(9) > 0, ioaf = read_one_group(fid, idfi(9), 40, 3); end;
 
        %...Doppler numbers
        if idfi(10) > 0, iodf = read_one_group(fid, idfi(10), 120, 1); end;

        %...frequency table
        if idfi(11) > 0, ftof = read_one_group(fid, idfi(11), 15, 8); end;

        %...O-trace F1 points
        
        %...virtual height
        if idfi(12) > 0
            if idfi(80) >= 2    % SAO V4.0
                otf1 = read_one_group(fid, idfi(12), 15, 8);
            else    % SAO V3.0 AND LOWER
            end
        end
        
        %...true height
        if idfi(13) > 0
            if idfi(80) >= 2    % SAO V4.0
                othf1 = read_one_group(fid, idfi(13), 15, 8);
            else    % SAO V3.0 AND LOWER
            end
        end

        %...amplitudes
        if idfi(14) > 0, ioaf1 = read_one_group(fid, idfi(14), 40, 3); end;

        %...Doppler number
        if idfi(15) > 0, iodf1 = read_one_group(fid, idfi(15), 120, 1); end;
 
        %...frequency table
        if idfi(16) > 0, ftof1 = read_one_group(fid, idfi(16), 15, 8); end;

        %...O-trace E points
        
        %...virtual heights
        if idfi(17) > 0
            if idfi(80) >= 2    % SAO V4.0
                ote = read_one_group(fid, idfi(17), 15, 8);
            else    % SAO V3.0 AND LOWER
            end
        end
        
        %...true height
        if idfi(18) > 0
            if idfi(80) >= 2    % SAO V4.0
                othe = read_one_group(fid, idfi(18), 15, 8);
            else    % SAO V3.0 AND LOWER
            end
        end
 
        %...amplitudes
        if idfi(19) > 0, ioae = read_one_group(fid, idfi(19), 40, 3); end;

        %...Doppler numbers
        if idfi(20) > 0, iode = read_one_group(fid, idfi(20), 120, 1); end;
 
        %...frequency table
        if idfi(21) > 0, ftoe = read_one_group(fid, idfi(21), 15, 8); end;
 
% ;...X-trace F2 points
% ;...virtual heights
%  If(IDFI(22-1) Gt 0) Then Begin
%   If(IDFI(80-1) Ge 2) Then Begin
%    XTF = FltArr(IDFI(22-1))
%    Readf, IU, Format = FM1, XTF  ; SAO V4.0
%   EndIf Else Begin
%    IXTF = IntArr(IDFI(22-1))
%    Readf, IU, Format = FM1, IXTF ; SAO V3.0 AND LOWER
%   EndElse
%  EndIf
% 
% ;...amplitudes
%  If(IDFI(23-1) Gt 0) Then Begin
%   IXAF = IntArr(IDFI(23-1))
%   Readf, IU, Format = FM10, IXAF
%  EndIf
% 
% ;...Doppler numbers
%  If(IDFI(24-1) Gt 0) Then Begin
%   IXDF = IntArr(IDFI(24-1))
%   Readf, IU, Format = FM7, IXDF
%  EndIf
% 
% ;...frequency table
%  If(IDFI(25-1) Gt 0) Then Begin
%   FTXF = FltArr(IDFI(25-1))
%   Readf, IU, Format = FM8, FTXF
%  EndIf
% 
% ;...X-trace F1 points
% ;...virtual heights
%  If(IDFI(26-1) Gt 0) Then Begin
%   If(IDFI(80-1) Ge 2) Then Begin
%    XTF1 = FltArr(IDFI(26-1))
%    Readf, IU, Format = FM1, XTF1  ; SAO V4.0
%   EndIf Else Begin
%    IXTF1 = FltArr(IDFI(26-1))
%    Readf, IU, Format = FM1, IXTF1 ; SAO V3.0 AND LOWER
%   EndElse
%  EndIf
% 
% ;...amplitudes
%  If(IDFI(27-1) Gt 0) Then Begin
%   IXAF1 = IntArr(IDFI(27-1))
%   Readf, IU, Format = FM10, IXAF1
%  EndIf
% 
% ;...Doppler numbers
%  If(IDFI(28-1) Gt 0) Then Begin
%   IXDF1 = IntArr(IDFI(28-1))
%   Readf, IU, Format = FM7,IXDF1
%  EndIf
% 
% ;...frequency table
%  If(IDFI(29-1) Gt 0) Then Begin
%   FTXF1 = FltArr(IDFI(29-1))
%   Readf, IU, Format = FM8, FTXF1
%  EndIf
% 
% ;...X-trace E points
% ;...virtual heights
%  If(IDFI(30-1) Gt 0) Then Begin
%   If(IDFI(80-1) Ge 2) Then Begin
%    XTE = FltArr(IDFI(30-1))
%    Readf, IU, Format = FM1, XTE  ; SAO V4.0
%   EndIf Else Begin
%    IXTE = IntArr(IDFI(30-1))
%    Readf, IU, Format = FM1, IXTE ; SAO V3.0 AND LOWER
%   EndElse
%  EndIf
% 
% ;...amplitudes
%  If(IDFI(31-1) Gt 0) Then Begin
%   IXAE = IntArr(IDFI(31-1))
%   Readf, IU, Format = FM10, IXAE
%  EndIf
% 
% ;...Doppler numbers
%  If(IDFI(32-1) Gt 0) Then Begin
%   IXDE = IntArr(IDFI(32-1))
%   Readf, IU, Format = FM7, IXDE
%  EndIf
% 
% ;...frequency table
%  If(IDFI(33-1) Gt 0) Then Begin
%   FTXE = FltArr(IDFI(33-1))
%   Readf, IU, Format = FM8, FTXE
%  EndIf
% 
% ;...median amplitude of F echo
%  If(IDFI(34-1) Gt 0) Then Begin
%   MEDF = IntArr(IDFI(34-1))
%   Readf, IU, Format = FM6, MEDF
%  EndIf
% ;...median amplitude of E echo
%  If(IDFI(35-1) Gt 0) Then Begin
%   MEDE = IntArr(IDFI(35-1))
%   Readf, IU, Format = FM6, MEDE
%  EndIf
% ;...median amplitude of Es echo
%  If(IDFI(36-1) Gt 0) Then Begin
%   MEDES = IntArr(IDFI(36-1))
%   Readf, IU, Format = FM6, MEDES
%  EndIf
% 
        %...F2 layer true height parameters
        if idfi(37) > 0, thf2 = read_one_group(fid, idfi(37), 10, 11); end;
        
        %...F1 layer true height parameters
        if idfi(38) > 0, thf1 = read_one_group(fid, idfi(38), 10, 11); end;

        %...E layer true height parameters
        if idfi(39) > 0, the = read_one_group(fid, idfi(39), 10, 11); end;        
 
        % ...valley parameters from Polan and NhPc version 2.01
        if idfi(40) > 0
            if idfi(80) >= 2
                qpcoef = read_one_group(fid, idfi(40), 6, 20);
            else
            end
        end
         
        %...edit flags
        %...NOTE: FOR OLD DATA, THIS INCLUDES BOTH THE CHARACTERISTCS FLAG
        %         AND THE TRACE+PROFILE FLAG
        if idfi(41) > 0, iedf = read_one_group(fid, idfi(41), 120, 1); end;
 
        %...Valley parameters from NhPc version 3.01 and greater Sept. 1993
        if idfi(42) > 0, thval = read_one_group(fid, idfi(42), 10, 11); end;

        %...O-trace sporadic-E
        
        %...virtual heights
        if idfi(43) > 0
            if idfi(80) >= 2    %  SAO V4.0
                otse = read_one_group(fid, idfi(43), 15, 8);
            else    % SAO V3.0 AND LOWER
            end
        end

        %...amplitudes
        if idfi(44) > 0, ioase = read_one_group(fid, idfi(44), 40, 3); end;

        %...Doppler numbers
        if idfi(45) > 0, iodse = read_one_group(fid, idfi(45), 120, 1); end;

        %...frequency table
        if idfi(46) > 0, ftose = read_one_group(fid, idfi(46), 15, 8); end;
 
% ;...O-trace - Auroral E layer
% ;...virtual heights
%  If(IDFI(47-1) Gt 0) Then Begin
%   If(IDFI(80-1) Ge 2) Then Begin
%     OTSE = FltArr(IDFI(47-1))
%     Readf, IU, Format = FM1, OTSE  ; SAO V4.0
%     IOTSE = Fix(OTSE)
%   EndIf Else Begin
%    IOTSE = IntArr(IDFI(47-1))
%    Readf, IU, Format = FM1, IOTSE ; SAO V3.0 AND LOWER
%    OTSE = Float(IOTSE)
%   EndElse
%  EndIf
% 
% ;...amplitudes
%  If(IDFI(48-1) Gt 0) Then Begin
%   IOASE = IntArr(IDFI(48-1))
%   Readf, IU, Format = FM10, IOASE
%  EndIf
% 
% ;...Doppler numbers
%  If(IDFI(49-1) Gt 0) Then Begin
%   IODSE = IntArr(IDFI(49-1))
%   Readf, IU, Format = FM7, IODSE
%  EndIf
% 
% ;...frequency table
%  If(IDFI(50-1) Gt 0) Then Begin
%   FTOSE = FltArr(IDFI(50-1))
%   Readf, IU, Format = FM8, FTOSE
%  EndIf

        %...N(h) Tabulation

        if idfi(51) > 0, htab = read_one_group(fid, idfi(51), 15, 8); 
        else htab = 80 : 5 : 1000; end
        
        if idfi(52) > 0, ftab = read_one_group(fid, idfi(52), 15, 8); 
        else ftab = repmat(NaN, numel(htab), 1); end
        
        if idfi(53) > 0, ntab = read_one_group(fid, idfi(53), 15, 8); 
        else ntab = repmat(NaN, numel(htab), 1); end
        
        
        %...Qualifying Letters
        if idfi(54) > 0, ql = read_one_group(fid, idfi(54), 120, 1); end;

        %...Descriptive Letters
        if idfi(55) > 0, dl = read_one_group(fid, idfi(55), 120, 1); end;

        %...Edit Flags - Traces and Profile
        if idfi(56) > 0, iedftp = read_one_group(fid, idfi(56), 120, 1); end;

    end
    
%    output = [];

    year = str2num(opmsg(3:6)); month = str2num(opmsg(10:11)); 
    dom = str2num(opmsg(12:13));
    hour = str2num(opmsg(14:15)); minute = str2num(opmsg(16:17)); 
    second = str2num(opmsg(18:19));           
    time = datenum(year, month, dom, hour, minute, second);
    
    nTab = struct('height',htab,'critfreq',ftab,'electdens',ntab);
    output = struct('scaled', scaled, 'time', time, 'nhtab', nTab);

%    
% fig : 
% nelg: # of elements in current group.
% nel: # of elements at each line.
% ndep: # of digits (field width) at each element.
%
function output = read_one_group(fid, nelg, nel, ndep)

    for i = 1 : ceil(nelg / nel)        
        if i == 1, tmp = fgetl(fid); else ...
            tmp = cat(2, tmp, fgetl(fid)); end;        
    end
    
   [dummy, nchar] = size(tmp);
   output = str2num(reshape(tmp, ndep, nchar / ndep)');
