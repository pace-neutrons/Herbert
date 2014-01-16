function efix = check_efix_defined_correctly(this)
% get efix value defined by the class or message
% why it is not defined
%
%
% $Revision$ ($Date$)
%

if isempty(this.loader_stor)
    efix = this.efix_stor;
else
    if ismember('efix',this.loader_stor.defined_fields())
        efix = this.loader_stor.efix;
    else
        efix = this.efix_stor;
    end
end

if isempty(efix)
    return;
end
if isempty(this.en)
    return
end


if this.emode == 1
    bin_bndry = this.en(end);
    if (efix<bin_bndry)        
        efix = sprintf('Emode=1 and efix incompartible with max energy transfer, efix: %f max(dE): %f',efix,bin_bndry);
    end
elseif this.emode == 2
    bin_bndry = this.en(1);
    if efix+bin_bndry<0
        efix = sprintf('Emode=2 and efix is incompartible with min energy transfer, efix: %f min(dE): %f',efix,bin_bndry);
    end
else
    efix = 'no efix for elastic mode';
end
