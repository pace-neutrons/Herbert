function pdf = recompute_pdf_ (obj)
% Compute the pdf_table object for the moderator pulse shape
%
%   >> pdf = recompute_pdf_ (moderator)
%
% Input:
% -------
%   moderator   IX_moderator object (scalar only)
%
% Output:
% -------
%   pdf         pdf_table object


if ~isscalar(obj)
    error('IX_moderator:recompute_pdf_:invalid_argument',...
        'Method only takes a scalar object')
end

if ~obj.valid_
    error('IX_moderator:recompute_pdf_:invalid_argument',...
        'Moderator object is not valid')
end

models= obj.pulse_models_;
model = obj.pulse_model_;

if models.match('ikcarp',model)
    pdf = ikcarp_recompute_pdf (obj.pp_);
    
elseif models.match('ikcarp_param',model)
    pdf = ikcarp_param_recompute_pdf (obj.pp_, obj.energy_);
    
elseif models.match('table',model)
    pdf = table_recompute_pdf (obj.pp_);
    
elseif models.match('delta_function',model)
    pdf = delta_function_recompute_pdf (obj.pp_);
    
else
    error('IX_moderator:recompute_pdf_:invalid_argument',...
        'Unrecognised moderator pulse model for computing pdf_table')
end

end
