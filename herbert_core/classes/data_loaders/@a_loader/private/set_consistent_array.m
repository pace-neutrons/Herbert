function this = set_consistent_array(this,field_name,value)
% set consistent data array
% and break connection between the class and data file -- currently
% disabled
%
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)
%

if isempty(value)
    if isempty(this.file_name)
        this=this.delete();
    else
        this.S_=[];
        this.ERR_=[];
    end
    return
end

this.(field_name) = value;
%this.data_file_name_ = '';

if strcmp(field_name,'en_')
    sig_size = [];
    if ~isempty(this.S_)
        sig_size = size(this.S_);
    else
        if ~isempty(this.ERR_)
            sig_size = size(this.ERR_);
        end
    end
    if ~isempty(sig_size)
        if size(value,1)== sig_size(1) % assigned energy points. Needs conversion in histogram.
            % DO we need to change signal, considering change in the binning?
            bins = value(2:end)-value(1:end-1);
            edges = [(value(1:end-1)-0.5*bins);value(end)-0.5*bins(end);(value(end)+0.5*bins(end))];
            this.en_ = edges;
        end
    end
else
    this.n_detindata_ = size(value,2);
end


