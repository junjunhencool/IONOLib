 function [varargout]=readhdf_ao_pwr(fname); 
% function [vargout]=readhdf(fname); 
% READ data in HDF format
% Convention for Arecibo Power Profiles:
%  time,ht,profs,azs,zen,date(1)  
% Data in HDF format can be manipulated with  matlab function hdfsd().  
% See help for a complete description.
% Power profile HDF files have 6 datasets (height,time,power,azs,zen,date)    

SD_id = hdfsd('start',fname,'rdonly'); % Initializes the SD interface for 
                                       % a particular file;

nout=nargout;
[ndatasets,nglobal_attr,status] = hdfsd('fileinfo',SD_id);
      %    Returns information about the content of a file
      %    Power profile files -> ndatasets=3  
      %    0. heights, 
      %    1. times
      %    2. data
      %    Index for data sets runs from 0: ndatasets-1

  if(nout > ndatasets)
    nout
    ndatasets
    error('Too many output arguments');
  end 


for i=1:nout
 sds_id(i) = hdfsd('select',SD_id, i-1); % last parameter: 0 to ndatasets-1
 [name,rank,ds,data_type,nattrs,status] = hdfsd('getinfo',sds_id(i));
 [varargout{i},status]=hdfsd('readdata',sds_id(i),zeros(1,rank),[],ds); 
       % last 3 parameters are: 
       % zeros(1,rank) -  first element
       % []            -  increment
       % dimsizes      -  number of elements  
 
       % 2-D array, last 3 parameters must be vectors 
       % [0 0]           -  first element
       % [1 1]           -  increments for each dimension
       % [ds(1) ds(2)]   -  number of elements for each dimension 
   status = hdfsd('endaccess',sds_id(i)); % Close data sets and files
end
  status = hdfsd('end',SD_id); 
