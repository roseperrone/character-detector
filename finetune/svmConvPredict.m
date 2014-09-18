function [P] = svmConvPredict(params, netconfig, data, batchsize)
addpath(genpath('.'));



svmparams  = params(1:(netconfig.xsize+1)*(netconfig.ysize));
convparams = params(1+(netconfig.xsize+1)*(netconfig.ysize):end);


% Convert Params to CStack
stack = params2cstack(convparams, netconfig);

% Data should be a 4d Array
imw = size(data, 1);
imh = size(data, 2);
imch = size(data, 3);
numcases = size(data, 4);

% Assume that netconfig should also include the imwidth imheight imch
assert(netconfig.imwidth == imw);
assert(netconfig.imheight == imh);
assert(netconfig.imch == imch);

% % Forward prop
% X = feedForwardCStack(reshape(data, imw*imh*imch, numcases), imw, imh, imch, stack);
% X = single(X);

%%
if 1==0 %debug == true && exist(sprintf('results/convnet_predict_%s_gpu.mat', dataName))
%     filename = sprintf('results/convnet_predict_%s_gpu.mat', dataName);
%     load(filename, 'X');
else
    % Forward prop
    %batchsize = 500;
    
    l = size(data,4);
    numbatches = ceil(l/ batchsize);
    
    fprintf('Predicting -- feedForward for svm, %d batches...\n', numbatches);
    X = [];
    for i=1:numbatches
        t=tic;
        fprintf('  batch %d/%d  ', i, numbatches);
        batchdata = data(:, :, :, (i-1)*batchsize + 1:min(i*batchsize, l));
        Xt = feedForwardCStack(reshape(batchdata, imw*imh*imch, size(batchdata, 4)), imw, imh, imch, stack);
        toc(t)
        X = [X, double(Xt)];
    end
    
end

%%

% N features M examples
% K distinct classes (1 to K)
K = netconfig.ysize;
[N,M] = size(X);
theta = reshape(svmparams(1:N*(K)), K, N);
bias  = reshape(svmparams((1+N*(K)):end), K, 1);
Zx = bsxfun(@times, theta, X(:,1)');
P=bsxfun(@plus, theta * X, bias);























end