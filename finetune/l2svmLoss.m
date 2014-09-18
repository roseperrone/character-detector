function [loss, g, od] = l2svmLoss(wb,X,y,K,C)

% [loss, g, od] = l2svmLoss(wb,X,y,C,K)
% L2 SVM with biases (based off Adam's)
%
% wb are the weight/bias parameters
% X is a data matrix with examples in columns
% y are labels (either as a row or column is fine)
%   labels should be from 1 -- K
% C svm-cost (weighting relative to the weight regularization term)
% K number of labels
%
% Note: A bias term is added (models the priors over each class)
%       wb is expected to be of length (N+1)*(K-1)
%
% N features M examples
% K distinct classes (1 to K)
%fprintf('C: %d, lambda: %d\n', C, 1/C);
[N,M] = size(X);
theta = reshape(wb(1:N*K), K, N);
bias  = reshape(wb((1+N*K):end), K, 1);

% Compute Margin 
ff  = bsxfun(@plus, theta * X, bias);
if (size(y, 2) ~= M)
    y = y';
end
Y   = bsxfun(@(y,ypos) 2*(y==ypos)-1, y, (1:K)');

margin = max(0, 1 - Y .* ff);
loss = (0.5 * sum(theta(:).^2)) + C * sum(mean(margin.^2, 2));

od = - 2*C/M * (margin .* Y);

gw = od * X';
gw = theta + gw;
gb = sum(od, 2);

g  = [gw(:) ; gb(:)];

if (nargout == 3)
    %% TODO: GRADIENT CHECK OD
    
    od = theta' * od*M;
end

end
