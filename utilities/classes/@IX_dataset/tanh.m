function w = tanh (w1)
% Implement tanh(w1) for objects
%
%   >> w = tanh(w1)
%

w = IX_dataset.unary_op_manager (w1, @tanh_single);
