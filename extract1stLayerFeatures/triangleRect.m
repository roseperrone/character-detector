function output = triangleRect(x, alpha, flat_grad)

global usegpu gpusingletype;

%implements this function
%
%\              /
% \            / 
%  \          /
%   \____0___/
%   -alpha  alpha
%  
% 
%
%

if ~exist('alpha', 'var') || isempty(alpha)
     alpha = 0.5;
%    alpha = 0.1;
end

if ~exist('flat_grad', 'var') || isempty(flat_grad)
    flat_grad = 0.0001;
end
output = zeros(size(x,1),size(x,2));

if strcmp(usegpu, 'gpumat')
    output = GPUsingle(output);
end

%alpha is positive
assert(alpha > 0);
% x<-alpha
idx = x<-alpha;
% output(idx) = x(idx) + (1-flat_grad) * alpha;
output = abs(x .* idx + idx * (1-flat_grad)*alpha);
%-alpha <= x <=alpha
idx = (x<=alpha).*(x>=-alpha)>0;
% output(idx) = x(idx) * flat_grad;
output = abs(output + x .* idx * flat_grad);
% x>-alpha
idx = x>alpha;
% output(idx) = x(idx) - (1-flat_grad) * alpha;
output = output + x .* idx - idx * (1-flat_grad)*alpha;

end
