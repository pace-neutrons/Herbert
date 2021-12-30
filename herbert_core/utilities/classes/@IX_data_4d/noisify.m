function obj_out = noisify (obj, varargin)
% Adds random noise to an IX_dataset_4d object or array of IX_dataset_4d objects
%
%   >> obj_out = noisify (obj)
%           Add noise with Gaussian distribution, with standard deviation
%           = 0.1*(maximum y value)
%
%   >> obj_out = noisify (obj, factor)
%           Add noise with Gaussian distribution, with standard deviation
%           = factor*(maximum y value)
%
%   >> obj_out = noisify (obj, 'poisson')
%           Add noise with Poisson distribution, where the mean value at
%           a point is the value y

% -----------------------------------------------------------------------------
% <#doc_def:>
%   doc_dir = fullfile(fileparts(which('IX_dataset')),'_docify')
%
%   doc_file = fullfile(doc_dir,'doc_noisify_method.m')
%
%   object = 'IX_dataset_4d'
%   method = 'noisify'
% -----------------------------------------------------------------------------
% <#doc_beg:> IX_dataset
%   <#file:> <doc_file>
% <#doc_end:>
% -----------------------------------------------------------------------------


obj_out = noisify_ (obj);
