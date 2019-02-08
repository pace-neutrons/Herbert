function [varargout]=load_data(this,new_file_name)
% function loads soe_h5  data into run_data structure
%
% this fucntion is the method of loader_speh5 class
%
% this function has to have its eqivalents in all other loader classes
% as all loaders are accessed through common interface.
%
%
% $Revision$ ($Date$)
%
if exist('new_file_name','var')
    this.file_name =new_file_name ;
    if ~H5F.is_hdf5(this.file_name)
        error('LOAD_SPEH5:invalid_argument','file %s is not proper hdf5 file\n',this.file_name);
    end    
else
    if isempty(this.file_name)
        error('LOAD_SPEH5:load_data',' input spe_h5 file is not defined\n')
    end
end
file_name= this.file_name ;

ver=hdf5read(file_name,'spe_hdf_version');
if ver>=2
    this.efix=hdf5read(file_name,'Ei');
else
    this.efix=NaN;
end
this.speh5_version=ver;
data{1} = hdf5read(file_name,'S(Phi,w)');
data{2} = hdf5read(file_name,'Err');
if isempty(this.en)
    data{3} = hdf5read(file_name,'En_Bin_Bndrs');
    this.en  = data{3};
else
    data{3} = this.en;
end
% eliminate symbolic NaN-s (build according to ASCII agreement)
S = data{1};
nans = (S(:,:)<-1.e+29);
data{1}(nans) = NaN;
data{2}(nans) = 0;

hc=herbert_config();
ziustyle = hc.zero_intensity_uncertainty(); % possible values: 0, 'minimum uncertainty', 'maximum uncertainty'
if ischar(ziustyle)
    switch lower(ziustyle(1:3))
        case 'min'; ufcn=@min;
        case 'max'; ufcn=@max;
    end
    replacement_ziu = ufcn( data{2}(data{2}>0) ); % minimum or maximum non-zero uncertainty
    % apply this only zero-intensity zero-uncertainty points:
    data{2}(data{1}==0 & data{2}==0) = replacement_ziu;
elseif isnumeric(ziustyle) && ziustyle~=0
    data{2}(data{1}==0 & data{2}==0) = ziustyle;
end

 % set also all dependent on S variables
this.S_   = data{1};
this.ERR_ = data{2};



if nargout==1
    varargout{1}=this;
else
    min_val = nargout;
    if min_val>3;
        min_val=3;
        varargout{4}=this;
    end
    varargout(1:min_val)={data{1:min_val}};
    
end
