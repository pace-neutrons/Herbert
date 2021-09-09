function obj_out = rebin_IX_dataset_single_ (obj, iax, xdescr, is_descriptor,...
        is_boundaries, resolved, integrate_data, point_average_method)
    
    
niax = numel(iax);

% Compute the output bin boundaries for unresolved axes (i.e. -Inf or +Inf,
% or a binning interval in a descriptor requires reference values to be 
% retained)
ishist = ishistogram_(obj);
xref = obj.xyz_;

if all(resolved)
    xrebin = xdescr;
else
    xrebin = cell(1,niax);
    for i = 1:niax
        if ~resolved(i)
            xrebin{i} = rebin_boundaries_from_binning_description ...
                (xdescr{i}, is_descriptor(i), is_boundaries(i), ...
                xref{iax(i)}, ishist(iax(i)));
        else
            xrebin{i} = xdescr{i};
        end
    end
end

% Check that the case of a single bin of zero width corresponds to point
% data and has data at that point. Change point_average_method to 'average'
% if OK.
for i = 1:niax
    if numel(xrebin{i})==2 && diff(xrebin{i})==0
        if ~ishist(iax(i))
            val = xrebin{1}(1);
            if upper_index(xref{iax(i)},val) >= lower_index(xref{iax(i)},val)
                point_average_method(i) = 'average';
            else
                error('HERBERT:rebin_IX_dataset_single_:invalid_argument',...
                    ['Attempting to rebin along point axis, %s direction, ',...
                    'with zero width bin at which there is no data'], iax(i))
            end
        else
            error('HERBERT:rebin_IX_dataset_single_:invalid_argument',...
                ['Attempting to rebin along histogram axis, %s direction, ',...
                'with zero width bin'], iax(i))
        end
    end
end
    
% Now perform rebinning along each rebin axis in succession
xout = obj.xyz_;
sout = obj.signal_;
eout = obj.error_;
xdistout = obj.xyz_distribution_;
for i = 1:niax
    if ishist(iax(i))
        % Histogram axis
        distr = [obj.xyz_distribution_(iax(i)), ~integrate_data];
        [sout, eout] = rebin_histogram (xref{iax(i)}, sout, eout,...
            iax(i), xrebin{i}, distr);
        xout{iax(i)} = xrebin{i};
        xdistout(iax(i)) = distr(2);
        
    else
        % Point axis
        if strcmp(point_average_method, 'interpolate')
            % Trapezoidal integration method
            distr = ~integrate_data;
            [sout, eout] = integrate_points (xref{iax(i)}, sout, eout,...
                iax(i), xrebin{i}, distr);
            xout{iax(i)} = xrebin{i};
            xdistout(iax(i)) = distr;
            
        elseif strcmp(point_average_method, 'average')
            % Point averaging method
            if ~integrate_data
                % Average points; retain only point positions
                [xout{iax(i)}, sout, eout] = average_points (xref{iax(i)},...
                    sout, eout, iax(i), xrebin{i});
            else
                % Integrate: average points, multiply by bin width; retain
                % all bins as cannot drop bins in histogram data
                [xout{iax(i)}, sout, eout] = average_points (xref{iax(i)},...
                    sout, eout, iax(i), xrebin{i}, 'integrate');
            end
            xdistout(iax(i)) = ~integrate_data;
            
        else
            error('HERBERT:rebin_IX_dataset_single_:invalid_argument',...
                'Unrecognised point averaging option - internal logic error')
        end
    end
end

% Create output object using input object as a template (retain captions)
obj_out = init (obj, xout, sout, eout, xdistout);
