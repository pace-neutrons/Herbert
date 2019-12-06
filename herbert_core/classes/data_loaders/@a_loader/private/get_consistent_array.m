function arr = get_consistent_array(this,field_name)
% method returns correct data array if all fields of the class are well
% defined and consistent or 'ill defined' otherwise;
%
%
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)
%


if ~isempty(this.(field_name))
    s_eq_err = all(size(this.S_)==size(this.ERR_));
    en_suits_s = (size(this.en_,1) ==size(this.S_,1)+1);
    
    if  s_eq_err && en_suits_s
        arr = this.(field_name);
    else
        arr='ill defined :';
        if ~s_eq_err
            arr=[arr,' size(Signal) ~= size(ERR)'];
            return;
        end
        if ~en_suits_s
            arr = [arr,' size(en) ~= size(S,1)+1'];
        end
    end
else
    arr = [];
end


