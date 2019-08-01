function varargout=parse_load_varargout(this,varargin)
%
%[S,ERR,en,this]=this.load_data();
%this=this.load_data();
%[S,ERR]=this.load_data();
%[S,ERR,en]=this.load_data();
ndet=this.num_det_if_emtpy;
nen = this.num_en_if_empty;
this.S_   = ones(nen,ndet);
this.ERR_ = zeros(nen,ndet);

if nargout==1
    varargout{1}=this;
else
    min_val = nargout;
    if min_val>3;
        min_val=3;
        varargout{4}=this;
    end
    
    if min_val==2
        varargout{1} = this.S_;
        varargout{2} = this.ERR_;
    elseif min_val==3
        varargout{1} = this.S_;
        varargout{2} = this.ERR_;
        varargout{3} = this.en_;
    end
end

