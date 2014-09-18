% Parameters: training data
%             cross validation data                
%             first layer features from K means, whitening parameters P, M
%             maxIter is an optional parameter specifying the number of iterations to
%                     perform fine tuning
%             lambda is an optional parameter for the L2 regularization penalty
function trainDetectorCNN(trainDataFile, cvDataFile, centroids, P, M, maxIter, lambda)

addpath(genpath('../finetune'));

if ~exist('maxiter')
  maxIter = 50;
end

if ~exist('lambda')
  % regularization constant found by cross-validation.
  % you can also do your own cross-validation.
  lambda = 0.001;
end

[trainX, trainY, testX, testY] = loadDataPreprocess(trainDataFile, cvDataFile, centroids, P, M);

inputDim = size(trainX);

batchsize = 500;

first_layer_size = 64;
num_channels = size(centroids, 1);
numlabels = 2;

%% Create a CStack
cstack{1}.actfunc  = @triangleRect;
cstack{1}.actfuncg = @triangleRectGrad;
cstack{1}.fch = num_channels;
cstack{1}.fx = 2;
cstack{1}.fy = 2;
cstack{1}.fs = 1;
cstack{1}.w = tanhInitRand(first_layer_size, cstack{1}.fx*cstack{1}.fy*cstack{1}.fch);
cstack{1}.b = zeros(first_layer_size, 1);
cstack{1}.px = 2;
cstack{1}.py = 2;
cstack{1}.ps = 2;
cstack{1}.poolfunc = @meanpool;
cstack{1}.poolfuncg = @meanpoolg;

imwidth = inputDim(1);
imheight = inputDim(2);
imch = inputDim(3);

[params, netconfig] = svmConvSetup(cstack, imwidth, imheight, imch, numlabels);

options.Method = 'lbfgs';
options.maxIter = maxIter;
options.maxFunEvals = 1.5*maxIter;
options.display = 'on';
options.TolFun = 1e-5;

[params, cost] = minFunc(@(p) svmConvLoss(p, netconfig, trainX, trainY, lambda, batchsize), params, options);

pred = svmConvPredict(params, netconfig, trainX, batchsize);
[~, predicted] = max(pred);
trainAcc = sum(predicted == trainY') / length(trainY);

pred = svmConvPredict(params, netconfig, testX, batchsize);
[~, predicted] = max(pred);
testAcc = sum(predicted == testY') / length(testY);

fprintf('train accuracy = %f, validation accuracy = %f\n', trainAcc, testAcc);

svmparams  = params(1:(netconfig.xsize+1)*(netconfig.ysize-1));
convparams = params(1+(netconfig.xsize+1)*(netconfig.ysize-1):end);
stack = params2cstack(convparams, netconfig);  

filename = '../models/detector_cnn.mat';
save(filename, 'trainAcc', 'testAcc', 'netconfig', 'stack', 'params', 'svmparams', 'cstack', 'centroids', 'P', 'M', '-v7.3');
fprintf('saved model to file %s\n', filename);
