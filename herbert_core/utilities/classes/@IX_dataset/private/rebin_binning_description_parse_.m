function [xdescr, is_descriptor, resolved] = ...
    rebin_binning_description_parse_(xin, bin_opts)
% Checks binning description has valid format, and returns in standard form
%
%   >> [xbounds, is_descriptor, resolved] = ...
%                   rebin_binning_description_parse_(xvals, bin_opts)
%
% Input:
% ------
%   xin         Binning description
%
%               The input binning description can take one of several
%               forms; the precise interpretation can depend on the value
%               of fields in the binning options argument detailed below.
%
%               The values -Inf and Inf have the meaning of lowest value
%               as determined a particular dataset; they will need to be
%               resolved elsewhere before the actual (finite) set of bin
%               boundaries or centres can be computed.
%
%       Empty:
%         [] or ''      Leave bins as they are (empty_is_one_bin==false)
%                       Equivalent to [-Inf,0,Inf]
%                           *OR*
%                       Single bin over full data range (empty_is_one_bin==true)
%                       Equivalent to [-Inf,Inf]
%
%       Scalar:
%         0             Leave bins as they are
%                       Equivalent to [-Inf,0,Inf]
%
%         dx            Equally spaced bins width dx centred on x=0 and
%                       over full range of data.
%                       Equivalent to [-Inf,dx,Inf]
%
%       Pair of values:
%         [xlo, xhi]    Keep original bins in the range xlo to xhi
%                       Equivalent to [xlo,0,xhi] (range_is_one_bin==false)
%                           *OR*
%                       Single bin (range_is_one_bin==true)
%
%       Three of more values:
%
%       If array_is_descriptor==true
%       ----------------------------
%         [x1, dx1, x2]
%         [x1, dx1, x2, dx2, x3,...xn]
%               where -Inf <= x1 <= x2 <= x3...<= xn <= Inf, or
%                     (only x1 and xn can possibly be infinite)
%
%               and
%
%               dx +ve: equal bin sizes between corresponding limits
%               dx -ve: logarithmic bins between corresponding limits
%                      (note: if dx1<0 then x1>0, dx2<0 then x2>0 ...)
%               dx=0  : retain existing bins between corresponding limits
%
%
%       If array_is_descriptor==false
%       -----------------------------
%       Descriptor defines bin boundaries or centres:
%         [x1, x2, x3,...xn]
%               where -Inf <= x1 <= x2 <=...<= xn <= Inf
%                     (only x1 and xn can possibly be infinite)
%
%
%   bin_opts    Options that control the interpretation of the binning
%               descriptions above. It is a structure with fields:
%
%       empty_is_one_bin        true:  [] or '' ==> [-Inf,Inf];
%                               false:          ==> [-Inf,0,Inf]
%
%     	range_is_one_bin        true:   [x1,x2] ==> one bin
%                               false:          ==> [x1,0,x2]
%
%      	array_is_descriptor     true:  interpret array of three or more
%                                      elements as descriptor
%                               false: interpret as actual bin boundaries
%                                      or bin centres
%
%      	values_are_boundaries   true:  interpret array as defining bin
%                                      boundaries
%                               false: interpret array as defining bin
%                                      centres
%
%
% Output:
% -------
%   xdescr      Binning description in one of the following forms:
%
%       is_descriptor==true
%       -------------------
%         [x1, dx1, x2]
%         [x1, dx1, x2, dx2, x3,...xn]
%               where -Inf <= x1 <= x2 <= x3...<= xn <= Inf, or
%                     (only x1 and xn can possibly be infinite)
%
%               and
%
%               dx +ve: equal bin sizes between corresponding limits
%               dx -ve: logarithmic bins between corresponding limits
%                      (note: if dx1<0 then x1>0, dx2<0 then x2>0 ...)
%               dx=0  : retain existing bins between corresponding limits
%
%
%       is_descriptor==false
%       --------------------
%       Descriptor defines bin boundaries:
%         [x1, x2, x3,...xn]
%               where -Inf <= x1 <= x2 <=...<= xn <= Inf
%                     (only x1 and xn can possibly be infinite)
%
%   is_descriptor   Logical array:
%                    - true if xbounds is a descriptor of bin boundaries;
%                    - false if xbounds contains actual bin boundaries
%
%   resolved        Logical flag:
%                    - true if infinities resolved in a descriptor or
%                      bin boundaries (and zero bin widths too in the case
%                      of a descriptor)
%                    - false if not


% Ensure xvals is empty, or is a numeric vector without NaNs
% (First pass of clearing out globally erroneous formats)
if ~isempty(xin) && (~isnumeric(xin) || ~isvector(xin) || any(isnan(xin)))
    error('HERBERT:rebin_binning_description_parse_:invalid_argument',...
        'Binning description must be numeric vector without NaNs, or empty')
end

% Treat all other cases
if isempty(xin)
    if bin_opts.empty_is_one_bin
        xdescr = [-Inf, Inf];
        is_descriptor = false;
        resolved = false;
    else
        xdescr = [-Inf,0,Inf];
        is_descriptor = true;
        resolved = false;
    end
    
elseif isscalar(xin)
    if xin == 0
        xdescr = [-Inf, 0, Inf];
        is_descriptor = true;
        resolved = false;
    else
        xdescr = [-Inf, xin, Inf];
        is_descriptor = true;
        resolved = false;
    end
    
elseif numel(xin) == 2
    if xin(1) <= xin(2)
        if bin_opts.range_is_one_bin
            xdescr = [xin(1), xin(2)];
            is_descriptor = false;
            resolved = (isfinite(xin(1)) && isfinite(xin(2)));
        else
            xdescr = [xin(1), 0, xin(2)];
            is_descriptor = true;
            resolved = false;
        end
    else
        error('HERBERT:rebin_binning_description_parse_:invalid_argument',...
            'Upper limit must be greater or equal to lower limit in a binning descriptor');
    end
    
elseif numel(xin) >= 3
    % Check -Inf and +Inf are being used correctly
    if xin(1) == Inf || xin(end) == -Inf || any(isinf(xin(2:end-1)))
        error('HERBERT:rebin_binning_description_parse_:invalid_argument',...
            ['Improper use of Inf in binning description: the first element can be -Inf,\n',...
            'the final element can be +Inf, and all in between must be finite']);
    end
    
    % Check binning description
    if bin_opts.array_is_descriptor
        % Binning description is declared to be a descriptor
        if rem(numel(xin), 2) == 1
            if all(diff(xin(1:2:end)) >= 0)   % monotonic increasing
                % Determine if descriptor has logarithmic bins only in
                % ranges where the lower descriptor value is positive
                xvals_lo = xin(1:2:end-1);
                % The first element could be -Inf; logarithmic bins
                % will definitely be invalid if xin(3)<=0 but could be
                % valid if xin(3)>0 (we cannot tell until -Inf is
                % resolved later on). The following is a trick to
                % permit -Inf as first element in descriptor and still
                % perform the test for certain invalidity
                if isinf(xvals_lo(1))
                    xvals_lo=xin(3);
                end
                dx = xin(2:2:end-1);
                if all(xvals_lo>0 | dx>=0)
                    xdescr = xin(:)';    % ensure is a row vector
                    is_descriptor = true;
                    resolved = (isfinite(xin(1)) && isfinite(xin(2)) &&...
                        all(dx~=0));
                else
                    error('HERBERT:rebin_binning_description_parse_:invalid_argument',...
                        'Rebin descriptor cannot have logarithmic bins for negative axis values');
                end
            else
                error('HERBERT:rebin_binning_description_parse_:invalid_argument',...
                    'Bin ranges in rebin descriptor must be strictly monotonic increasing');
            end
        else
            error('HERBERT:rebin_binning_description_parse_:invalid_argument',...
                'Rebin descriptor must have the form: [x1,dx1,x2, dx2,...xn]');
        end
        
    else
        % Binning decription is declared to be actual bin boundaries or bin
        % centres
        if all(diff(xin)>=0)
            xdescr = xin(:)';    % ensure is a row vector
            is_descriptor = false;
            resolved = (isfinite(xin(1)) && isfinite(xin(2)));
        else
            error('HERBERT:rebin_binning_description_parse_:invalid_argument',...
                ['Rebin values must be a monotonic increasing vector ',...
                'i.e. all bin widths >= 0']);
        end
    end
    
end
