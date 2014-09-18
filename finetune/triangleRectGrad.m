function grad = triangleRectGrad(x, y, alpha, flat_grad)

%implements gradient of this function
%
%\              /
% \            / 
%  \          /
%   \____0___/
%  -alpha  alpha
% 
%
%
%


if ~exist('alpha', 'var') || isempty(alpha)
    %alpha = 0.1;
    alpha = 0.5;
end
% 
if ~exist('flat_grad', 'var') || isempty(flat_grad)
    flat_grad = 0.0001;
end

%alpha is positive
assert(alpha > 0);

% x<-alpha
idx = x<-alpha;
grad = -idx;
%-alpha <= x <=alpha
idx = (x<=alpha).*(x>=-alpha)>0;
grad = grad + idx .* flat_grad;
% x>-alpha
idx = x>alpha;
grad = grad + idx .* 1;
end
