function [loss, grad] = svmConvLoss(params, netconfig, data, y, lambda, batchsize)

addpath(genpath('.'));

if nargin < 5
    lambda = 0;
end

svmparams  = params(1:(netconfig.xsize+1)*(netconfig.ysize));
convparams = params(1+(netconfig.xsize+1)*(netconfig.ysize):end);
% fprintf('svm size %d, conv size %d\n', length(svmparams), length(convparams));


% Convert Params to CStack
stack = params2cstack(convparams, netconfig);
% aa = dir('svmtempDs/');
% tempcnt = length(aa)-1;
% DD = double(stack{1}.w);
% save(sprintf('svmtempDs/svmtempD%d.mat', tempcnt), 'DD');

% Data should be a 4d Array
imw = size(data, 1);
imh = size(data, 2);
imch = size(data, 3);
numcases = size(data, 4);

% Assume that netconfig should also include the imwidth imheight imch
assert(netconfig.imwidth == imw);
assert(netconfig.imheight == imh);
assert(netconfig.imch == imch);

% Forward prop
%batchsize = 50;

l = size(data,4);
numbatches = ceil(l/ batchsize);
batchsize_act = zeros(1, numbatches);
loss = zeros(1, numbatches);
grad = zeros(length(params), numbatches);
for i=1:numbatches
%     fprintf('feedForward for batch %d/%d\n', i, numbatches);
    batchdata = data(:, :, :, (i-1)*batchsize + 1:min(i*batchsize, l));
    batchsize_act(i) = size(batchdata, 4);
    [X, savedfprop] = feedForwardCStack(reshape(batchdata, imw*imh*imch, batchsize_act(i)), imw, imh, imch, stack);
    batchy = y((i-1)*batchsize + 1:min(i*batchsize, l));
    X = double(X);
    [losst, svmgrad outderv] = l2svmLoss(svmparams, X, batchy, netconfig.ysize, 1/lambda);
    loss(i) = losst;
    
    
    % Backprop
    % Note: Code has been optimized for the dummy (it will not be computed)

    [~, stackgrad] = backPropCStack(reshape(batchdata, imw*imh*imch, batchsize_act(i)), imw, imh, imch, stack, outderv, savedfprop, true);

    % Convert Stack to Params
    convgrad = cstack2params(stackgrad);
    
    grad(:, i) = [svmgrad(:); convgrad(:)];
end

% svm Loss
if nargout == 1
    loss = sum(batchsize_act .* loss) / sum(batchsize_act);
elseif nargout >= 2
    loss = sum(batchsize_act .* loss) / sum(batchsize_act);
    grad = sum(repmat(batchsize_act, length(params), 1) .* grad, 2) / sum(batchsize_act);
end
end
