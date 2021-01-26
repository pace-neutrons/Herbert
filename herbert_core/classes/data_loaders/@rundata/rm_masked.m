function [S_m,Err_m,det_m]=rm_masked(this,ignore_nan,ignore_inf)
% method removes failed (NaN or Inf) data from the data array and deletes
% detectors, which provided such signal
%
if isempty(this.S)||isempty(this.ERR)||isempty(this.det_par)
    error('RUNDATA:rm_masked',' signal, error and detectors arrays have to be defined\n');
end
if any(size(this.S)~=size(this.ERR))||(size(this.S,2)~=numel(this.det_par.x2))
    error('RUNDATA:rm_masked',' signal error and detectors arrays are not consistent\n');
end
if ~exist('ignore_nan','var')
    ignore_nan = true;
end
if ~exist('ignore_inf','var')
    ignore_inf = true;
end


if ignore_nan && ignore_inf
    index_masked = (isnan(this.S)|(isinf(this.S))); % masked pixels
elseif ignore_nan
    index_masked = (isnan(this.S));
elseif ignore_inf
    index_masked = (isinf(this.S));
else
    S_m= this.S;
    Err_m = this.ERR;
    det_m = this.det_par;
    return
end
line_notmasked= ~any(index_masked,1);           % masked detectors (for any energy)

if get(herbert_config,'log_level')> 1
    [ne,ndet]=size(this.S);
    nnotmasked = sum(line_notmasked);
    if nnotmasked<ndet
        ndet_mask = ndet-nnotmasked;
        disp(['Masked additional ',num2str(ndet_mask),' detectors out of toal ',num2str(ndet), ' detectors'])
        disp(['This removes      ',num2str(ndet_mask*ne),' pixels out of total ',num2str(ne*ndet), ' pixels'])
    end
end

S_m  = this.S(:,line_notmasked);
Err_m= this.ERR(:,line_notmasked);
det = this.det_par;
det_fields = fields(det);
det_m = struct();
for i=1:numel(det_fields)
    field = det_fields{i};
    if ~ischar(det.(field))
        array = det.(field);
        det_m.(field) = array(line_notmasked);
    else
        det_m.(field) = det.(field);
    end
end
