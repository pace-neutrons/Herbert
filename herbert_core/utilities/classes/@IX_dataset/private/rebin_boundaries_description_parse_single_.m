function [xbounds, is_descriptor, any_lim_inf, any_dx_zero] = ...
    rebin_boundaries_description_parse_single_(bin_opts, xvals)
% Check binning description has valid format, and returns in standard form
%
%   >> [xbounds, any_lim_inf, is_descriptor, any_dx_zero] = ...
%   rebin_boundaries_description_parse_single_(bin_opts, xvals)
%
% Input:
% ------
%   bin_opts    Type check options: structure with fields
%                               empty_is_one_bin     true: [] or '' ==> [-Inf,Inf];
%                                                       false ==> [-Inf,0,Inf]
%                               range_is_one_bin        true: [x1,x2]  ==> one bin
%                                                       false ==> [x1,0,x2]
%                               array_is_descriptor     true:  interpret array of three or more elements as descripor
%                                                       false: interpet as actual bin boundaries
%                               values_are_boundaries   true:  intepret x values as bin boundaries
%                                                       false: interpret as bin centres
%
%   xvals       Binning description
%
%               The binning description can take one of several forms:
%       Empty:
%         [] or ''      Leave bins as they are (empty_is_one_bin==false)
%                       Equivalent to [-Inf,0,Inf]
%                           *OR*
%                       Single bin over full range of data (empty_is_one_bin==true)
%                       Equivalent to [-Inf,Inf]
%
%       Scalar:
%         0             Leave bins as they are
%                       Equivalent to [-Inf,0,Inf]
%
%         dx            Equally spaced bins width dx centred on x=0 and
%                       over full range of data.
%                       Equivalent to [-Inf,dx,Inf]  (note: must have dx>0)
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
%       - If values_are_boundaries==true, then the descriptor defines bin
%        boundaries:
%         [x1, dx1, x2]
%         [x1, dx1, x2, dx2, x3,...]
%               where -Inf < = x1 < x2 < x3...< xn <= Inf, and
%
%               dx +ve: equal bin sizes between corresponding limits
%               dx -ve: logarithmic bins between corresponding limits
%                      (note: if dx1<0 then x1>0, dx2<0 then x2>0 ...)
%               dx=0  : retain existing bins between corresponding limits
%
%       - If values_are_boundaries==false, then the descriptor defines
%        bin centres:
%         [x1, dx1, x2]             where x1<x2 x1 and x2 both finite and dx>0: bin centres at x1, x1+dx1, x1+2*dx1, ...
%
%       If array_is_descriptor==false
%       -----------------------------
%       Descriptor defines bin boundaries:
%         [x1, x2, x3,...xn]        where -Inf <= x1 < x2 <...< xn <= Inf
%
%
%
%
% Output:
% -------
%   xbounds     Binning description in one of the following forms:
%
%       Descriptor:     [x1,dx1,x2,dx2,...xn]
%                       where -Inf<=x1<x2<x3...<xn<=Inf; n>=2
%                        dx +ve: equal bin sizes between corresponding limits
%                        dx -ve: logarithmic bins between corresponding limits
%                              (note: if dx1<0 then x1>0, dx2<0 then x2>0 ...)
%                        dx=0  : retain existing bins between corresponding limits
%
%       Bin boundaries: [x1,x2,...xn]
%                       where -Inf<=x1<x2<x3...<xn<=Inf; n>=2
%
%   any_lim_inf     Logical array; an element is true if either or both limits
%                  are infinite
%
%   is_descriptor   Logical array; an element is true if xbounds is a descriptor
%                  of bin boundaries;
%                  or is false if xbounds contains actual bin boundaries
%
%   any_dx_zero     Logical array; an element is true if one or more dx in
%                  the corresponding descriptor is zero (false if is_descriptor==false)


% Ensure empty, or is numeric vector without NaNs
if ~isempty(xvals) && (~isnumeric(xvals) || ~isvector(xvals) || any(isnan(xvals)))
    error('HERBERT:rebin_boundaries_description_parse_single_:invalid_argument',...
        'Binning description must be numeric vector without NaNs, or empty')
end

% Treat all other cases
if isempty(xvals)
    if bin_opts.empty_is_one_bin
        xbounds=[-Inf,Inf]; any_lim_inf=true; is_descriptor=false; any_dx_zero=false;
    else
        xbounds=[-Inf,0,Inf]; any_lim_inf=true; is_descriptor=true; any_dx_zero=true;
    end
    
elseif isscalar(xvals)
    if xvals==0
        xbounds=[-Inf,0,Inf]; any_lim_inf=true; is_descriptor=true; any_dx_zero=true;
    else
        xbounds=[-Inf,xvals,Inf]; any_lim_inf=true; is_descriptor=true; any_dx_zero=false;
    end
    
elseif numel(xvals)==2
    if xvals(1)<xvals(2)
        if bin_opts.range_is_one_bin
            ok=true; xbounds=[xvals(1),xvals(2)]; any_lim_inf=any(isinf(xvals)); is_descriptor=false; any_dx_zero=false; mess='';
        else
            ok=true; xbounds=[xvals(1),0,xvals(2)]; any_lim_inf=any(isinf(xvals)); is_descriptor=true; any_dx_zero=true; mess='';
        end
    else
        ok=false; xbounds=[]; any_lim_inf=false; is_descriptor=false; any_dx_zero=false;
        mess='Upper limit must be greater than lower limit in a rebin descriptor';
    end
    
else
    if bin_opts.array_is_descriptor
        if bin_opts.values_are_boundaries
            if rem(numel(xvals),2)==1
                if all(diff(xvals(1:2:end)))>0    % strictly monotonic increasing
                    xvals_lo=xvals(1:2:end-1);
                    if isinf(xvals_lo(1)), xvals_lo=xvals(3); end    % permit -Inf as first element in descriptor
                    if all(xvals_lo>0 | xvals(2:2:end-1)>=0)
                        ok=true;
                        if size(xvals,1)>1, xbounds=xvals'; else, xbounds=xvals; end     % make row vector
                        any_lim_inf=isinf(xbounds(1))|isinf(xbounds(end));
                        is_descriptor=true;
                        if any(xvals(2:2:end)==0)
                            any_dx_zero=true;
                        else
                            any_dx_zero=false;
                        end
                        mess='';
                    else
                        ok=false; xbounds=[]; any_lim_inf=false; is_descriptor=false; any_dx_zero=false;
                        mess='Rebin descriptor cannot have logarithmic bins for negative axis values';
                    end
                else
                    ok=false; xbounds=[]; any_lim_inf=false; is_descriptor=false; any_dx_zero=false;
                    mess='Bin ranges in rebin descriptor must be strictly monotonic increasing';
                end
            else
                ok=false; xbounds=[]; any_lim_inf=false; is_descriptor=false; any_dx_zero=false;
                mess='Check rebin descriptor has correct number of elements';
            end
        else
            if numel(xvals)==3 && xvals(1)<xvals(3) && xvals(2)>0
                ok=true;
                xbounds=[xvals(1)-xvals(2)/2,xvals(2),xvals(3)+xvals(2)/2];
                any_lim_inf=isinf(xbounds(1))|isinf(xbounds(end));
                is_descriptor=true; any_dx_zero=false; mess='';
            else
                ok=false; xbounds=[]; any_lim_inf=false; is_descriptor=false; any_dx_zero=false;
                mess='Rebin descriptor for bin centres must have three elements in the form [xlo,dx,xhi], xlo<xhi and dx>0';
            end
        end
    else
        if all(diff(xvals)>0)
            ok=true;
            if size(xvals,1)>1, xbounds=xvals'; else, xbounds=xvals; end     % make row vector
            any_lim_inf=isinf(xbounds(1))|isinf(xbounds(end));
            is_descriptor=false; any_dx_zero=false; mess='';
        else
            ok=false; xbounds=[]; any_lim_inf=false; is_descriptor=false; any_dx_zero=false;
            mess='Rebin boundaries must be strictly monotonic increasing vector i.e. all bin widths > 0';
        end
    end
    
end
