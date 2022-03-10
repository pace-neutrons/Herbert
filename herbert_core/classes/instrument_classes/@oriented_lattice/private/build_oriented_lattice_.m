function [obj,remains] = build_oriented_lattice_(obj,varargin)
% build non-empty oriented lattice from any form of constructor input
% including positional arguments, defined in the order, returned by
% indepFields function (i.e. 'alatt','angdeg','psi','u','v'...etc.)
%
remains = {};
if isa(varargin{1},'oriented_lattice') % copy constructor
    obj = varargin{1};
elseif isstruct(varargin{1}) % strucure with oriented lattice fields
    obj = obj.from_bare_struct(input);
elseif isnumeric(varargin{1}) || ischar(varargin{1}) % the initialization is done by positional
    % arguments followed by key-value pairs or numeric positional arguments
    % followed (optionally) by key-value pairs
    key_names = obj.indepFields();
    [obj,remains] = obj.set_positional_and_key_val_arguments(...
        key_names,[],varargin{:});
else
    error('HERBERT:oriented_lattcie:invalid_argument',...
        ['oriented lattice may be constructed only with an input structure,'...
        ' containing the same fields as public fields of the oriented lattice itself or'...
        ' using constructor,containing positional arguments and key-value pairs']);
end
if ~isempty(remains)
    error('HERBERT:oriented_lattcie:invalid_argument',...
        'The lattice constructor provided with unrecognized extra argument(s): %s',...
        evalc('disp(remains)'));
end

[ok,mess,obj] = check_combo_arg_(obj);
if ~ok
    error('HERBERT:oriented_lattcie:invalid_argument',mess);
end
%
