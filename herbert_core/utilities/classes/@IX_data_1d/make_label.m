function [xlabel,slabel]=make_label(w)
% Create axis annotations from IX_dataset_1d object. All outputs are cellstr.
%
%   >> [xlabel,slabel]=make_label(w)

% If given array of objects, get labels for the first element

xlabel=make_label(w(1).x_axis);
[slabel,units_appended]=make_label(w(1).s_axis);

% Now address any distributions
str='';
if w(1).x_distribution && ~isempty(w(1).x_axis.units)
    str=[str,' / ',w(1).x_axis.units];
end
if ~isempty(str)
    if ~isempty(slabel)
        if units_appended
            slabel{end}=[slabel{end}(1:end-1),str,')'];
        else
            slabel{end}=[slabel{end},' (1',str,')'];
        end
    else
        slabel={['(1',str,')']};
    end
end
