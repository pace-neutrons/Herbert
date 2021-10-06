function warn_count = warning_deprecated_function (warn_count, func_name_new)
% Print deprecated function warning for a maximum number of times
%
%   >> warn_count = warning_deprecated_function (warn_count)
%   >> warn_count = warning_deprecated_function (warn_count, func_name)
%
%
% Input:
% ------
%   warn_count  Warning counter. Initialise as a persistent variable in the
%               calling function with the maximum number of times you want
%               to the message to be printed before the warning is silent
%
%   func_name   Name of replacement function, if there is one, to be added
%               as information to the warning message
%
% Output:
% -------
%   warn_count  Same variable as the input. It must be passed back to this
%               function by the caller as it counts the number of times the
%               function has been called.
%
%
% EXAMPLE of use in a function:
%
%       function [out1, out2,... = my_deprecated_function (arg1, arg2,...)
% 
%       persistent warn_count
%       if isempty(warn_count), warn_count = 3; end
%       new_function = 'my_replacement_function'
%       
%       warn_count = warning_deprecated_function (warn_count, new_function);
%
%               :
%       <body of function>
%               :



% Default is to print out the message 100 times
if isempty(warn_count)
    warn_count = 100;
end

% Print message if decrement still > 0
if warn_count > 0
    S = dbstack(1,'-completenames');
    if ~isempty(S)  % Caller is a function
        func_name = S(1).name;
        func_file = S(1).file;
        fmt = ['Warning: Deprecated function: %s \n(in file: %s)\n'];
        if nargin==1
            fprintf(2, fmt, func_name, func_file);
        else
            fmt = [fmt, 'Replace with function: %s\n'];
            fprintf(2, fmt, func_name, func_file, func_name_new);
        end
    end
end

% Decrease warning count by unity
warn_count = max(warn_count-1, 0);
