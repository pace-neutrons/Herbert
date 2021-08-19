function [xout, is_descriptor, is_boundaries, resolved] = ...
    rebin_binning_description_parse_(xin, bin_opts)
% Checks binning description has valid format, and returns in standard form
%
%   >> [xout, is_descriptor, resolved] = ...
%                       rebin_binning_description_parse_(xin, bin_opts)
%
% 
%
% Input:
% ------
%   xin         Binning description
%
%               The input binning description can take one of several
%               forms; the precise interpretation can depend on the value
%               of fields in the binning options argument detailed below.
%
%               The values -Inf and Inf have the meaning of lowest and
%               highest value as determined a particular dataset; they will
%               need to be resolved elsewhere later on before the actual
%               finite set of bin boundaries or centres can be computed.
%
%       Empty:
%         [] or ''  - empty_is_one_bin==false: 
%                       Leave bin boundaries/point positions as they are. 
%                       That is, make no changes along the axis.
%                       Equivalent to [-Inf,0,Inf]
%
%                           *OR*
%
%                   - empty_is_one_bin==true:
%                       Single bin over full data range
%                       Equivalent to [-Inf,Inf]
%
%                       hist data: lowest bin boundary to highest boundary.
%                       point data: lowest point position to highest.
%                           - 'ave': will average all points; OK if range=0
%                           - 'int': must have range>0, so will default to
%                                    'ave' if range=0
%
%       Scalar:
%         0             Leave bin boundaries/point positions as they are.
%                       That is, make no changes along the axis.
%                       Equivalent to [-Inf,0,Inf]
%
%         dx            Equally spaced bins width dx centred on x=0 and
%                       over full range of data (dx>0); or logarithmic bins
%                       centred on x=1 (dx<0)
%                       Equivalent to [-Inf,dx,Inf]
% 
%                       hist data: will encompass outer bin boundaries,
%                                  even if that means the outer bins have
%                                  width less than dx
%                       point data: will encompass outer point positions
%                                  even if that means the outer bins have
%                                  width less than dx
%                           - 'ave': will average all points; OK if range=0
%                           - 'int': must have range>0, so will default to
%                                    'ave' if range=0
%
%       Pair of values:
%         [xlo, xhi]- - range_is_one_bin==true:
%                       Single bin
%
%                           *OR*
%
%                     - range_is_one_bin==false:
%                       Keep original bin boundaries/point positions in the
%                       range xlo to xhi.
%                       Equivalent to [xlo,0,xhi]
%
%                       hist data: If the bin boundaries are not coincident
%                                  with xlo &/or xhi then the outer bin(s)
%                                  will have width less than dx
%                       point data: will encompass outer point positions
%                                  even if that means the outer bins have
%                                  width less than dx
%                           - 'ave': simply keeps points unaltered within
%                                  or at the edges of the range; ok if the
%                                  range=0
%                           - 'int': must have range>0
%
%                   
%       Three of more values:
%
%       If array_is_descriptor==true
%       ----------------------------
%       Bin boundaries or centres are generated by an algorithm:
%         [x1, dx1, x2]
%         [x1, dx1, x2, dx2, x3,...xn]
%               where -Inf <= x1 < x2 < x3...< xn <= Inf, and
%
%               dx +ve: equal bin sizes between corresponding limits
%               dx -ve: logarithmic bins between corresponding limits
%                      (note: if dx1<0 then x1>0, dx2<0 then x2>0 ...)
%               dx=0  : retain existing bins between corresponding limits
%
%
%       If array_is_descriptor==false
%       -----------------------------
%       Descriptor explicitly gives bin boundaries or centres:
%         [x1, x2, x3,...xn]
%               where -Inf <= x1 < x2 <...< xn <= Inf
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
%      	array_is_descriptor     For the case of a binning description with
%                              three or more elements:
%                               true:  interpret array of three or more
%                                      elements as descriptor
%                               false: interpret as actual bin boundaries
%                                      or bin centres
%
%      	values_are_boundaries   For the case of a binning description with
%                              three or more elements:
%                               true:  interpret array as defining bin
%                                      boundaries
%                               false: interpret array as defining bin
%                                      centres
%
%
% Output:
% -------
%   xout            Binning description in one of the following forms:
%
%       is_descriptor==true
%       -------------------
%         [x1, dx1, x2]
%         [x1, dx1, x2, dx2, x3,...xn]
%               where -Inf <= x1 < x2 < x3...< xn <= Inf  (n >= 2), and
%
%               dx +ve: equal bin sizes between corresponding limits
%               dx -ve: logarithmic bins between corresponding limits
%                      (note: if dx1<0 then x1>0, dx2<0 then x2>0 ...)
%               dx=0  : retain existing bins between corresponding limits
%
%       is_descriptor==false
%       --------------------
%       Binning description defines actual bin boundaries or centres:
%         [x1, x2, x3,...xn]
%               where -Inf <= x1 < x2 <...< xn <= Inf   (n >=2)
%
%       Two values can only ever be bin boundaries if is_descriptor==false
%
%       The special case of n=2, finite x1, x2 and x1=x2 is permitted (a
%       bin of zero width, which will be valid if point data, all points
%       with x=x1)
%
%       [Note that the input binning descriptions do not include the
%       possibility of asking for two bin centres. This was not a 
%       deliberate design decision, but emerged as prior functionality for
%       bin centres was enhanced. Retaining existing syntax is inconsistent
%       with allowing the two bin centres.]
%   
%
%   is_descriptor   Logical array:
%                    - true if xout is a descriptor of bin boundaries or 
%                           centres;
%                    - false if xout contains actual bin boundaries or
%                           centres
%
%   is_boundaries   Logical flag:
%                    - true if xout defines bin boundaries
%                    - false if xout defines bin centres
%                  [Note that -Inf and Inf always end up defining bin
%                   boundaries. This is a statement about the finite values
%                   of x1, x2,... that appear in a binning description]
%
%   resolved        Logical flag:
%                    - true if there are no infinities resolved in the 
%                      binning description, and no zero step sizes in
%                      binning descriptors
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
        xout = [-Inf, Inf];
        is_descriptor = false;
        resolved = false;
    else
        xout = [-Inf,0,Inf];
        is_descriptor = true;
        resolved = false;
    end
    
elseif isscalar(xin)
    if xin == 0
        xout = [-Inf, 0, Inf];
        is_descriptor = true;
        resolved = false;
    else
        xout = [-Inf, xin, Inf];
        is_descriptor = true;
        resolved = false;
    end
    
elseif numel(xin) == 2
    if (xin(1) < xin(2)) || (bin_opts.range_is_one_bin && xin(1)==xin(2))
        % We allow the special case of a single bin with width zero; the
        % case of binning descriptions with -Inf &/or Inf can be resolved
        % into this elsewhere, and is valid for the special case of point
        % data where all points have the same value of x==xin(1)==xin(2)
        if bin_opts.range_is_one_bin
            xout = [xin(1), xin(2)];
            is_descriptor = false;
            resolved = (isfinite(xin(1)) && isfinite(xin(2)));
        else
            xout = [xin(1), 0, xin(2)];
            is_descriptor = true;
            resolved = false;
        end
    else
        error('HERBERT:rebin_binning_description_parse_:invalid_argument',...
            'Upper limit must be greater than lower limit in a binning descriptor');
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
            if all(diff(xin(1:2:end)) > 0)   % strictly monotonic increasing
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
                    xout = xin(:)';    % ensure is a row vector
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
        if all(diff(xin)>0)
            xout = xin(:)';    % ensure is a row vector
            is_descriptor = false;
            resolved = (isfinite(xin(1)) && isfinite(xin(2)));
        else
            error('HERBERT:rebin_binning_description_parse_:invalid_argument',...
                ['Rebin values must be a strictly monotonic increasing vector ',...
                'i.e. all bin widths > 0']);
        end
    end
    
end

% Boundaries or centres:
is_boundaries = numel(xout)==2 || bin_opts.values_are_boundaries;
