% train a classifier model using precomputed first layer features
addpath(genpath('.'))
batchsize = 1000; maxinner = 300; addpath(genpath('.'));

%% Setup CV Data and Models
CV = true;
[trainingdata, traininglabels, testdata, testlabels, numlabels] = create_icdar_data(CV);

first_layer_size = size(trainingdata,3);
second_layer_size = 180;

imw = size(trainingdata,1); imh = size(trainingdata,2); imch = size(trainingdata,3);

%% Create a fstack
cstack{1}.actfunc  = @triangleRect;
cstack{1}.actfuncg = @triangleRectGrad;
cstack{1}.fch = size(trainingdata,3);
cstack{1}.fx = 2;
cstack{1}.fy = 2;
cstack{1}.fs = 1;
cstack{1}.b = zeros(second_layer_size, 1);
cstack{1}.px = 2;
cstack{1}.py = 2;
cstack{1}.ps = 2;
cstack{1}.poolfunc = @meanpool;
cstack{1}.poolfuncg = @meanpoolg;

train_err = [];
val_err = [];
times = [];
total_time = 0;
trainingdata = double(trainingdata);
testdata = double(testdata);
%% Run cross validation
addpath minFunc/
options.Method = 'lbfgs';
options.maxIter = maxinner;
options.display = 'on';
options.TolFun = 1e-5;
options.DerivativeCheck = 'off';
lambda = 0.001;
% uncomment to perform cross-validation
%Ls = [0.001,0.003,0.01,0.03,0.1,0.3];
%
%for ll = 1:length(Ls)
%    lambda = Ls(ll)
%    
%    cstack{1}.w = tanhInitRand(second_layer_size,cstack{1}.fx*cstack{1}.fy*cstack{1}.fch);
%    cstack{1}.b = zeros(second_layer_size, 1); % biases
%    [params, netconfig] = svmConvSetup(cstack, imw, imh, imch, numlabels);
%size(params)
%    [params, cost] = minFunc( @(p) svmConvLoss(p, netconfig, trainingdata, traininglabels, lambda, batchsize), params, options);
%    
%    [P] = svmConvPredict(params, netconfig, testdata, batchsize);
%    [~, predictedtestlabels] = max(P);
%    valerr = sum(predictedtestlabels~=testlabels)/ length(testlabels); % validation error
%    [P] = svmConvPredict(params, netconfig, trainingdata, batchsize);
%    [~, predictedtraininglabels] = max(P);
%    trainerr = sum(predictedtraininglabels~=traininglabels)/ length(traininglabels); % training error
%    fprintf('trainerr = %f, valerr = %f\n', trainerr, valerr);
%    train_err = [train_err, trainerr];
%    val_err  = [val_err, valerr];
%end
%% get best lambda
%[~, bestCVNum] = min(val_err);
%lambda = Ls(bestCVNum);

%% Setup actual training Data and Models
CV = false;
[trainingdata, traininglabels, testdata, testlabels, numlabels] = create_icdar_data(CV);

cstack{1}.w = tanhInitRand(second_layer_size,cstack{1}.fx*cstack{1}.fy*cstack{1}.fch);
cstack{1}.b = zeros(second_layer_size, 1); % biases

[params, netconfig] = svmConvSetup(cstack, imw, imh, imch, numlabels);

[params, cost] = minFunc( @(p) svmConvLoss(p, netconfig, trainingdata, traininglabels, lambda, batchsize), params, options);

[P] = svmConvPredict(params, netconfig, testdata, batchsize);
[~, predictedtestlabels] = max(P);
testerr = sum(predictedtestlabels~=testlabels)/ length(testlabels); % test error
[P] = svmConvPredict(params, netconfig, trainingdata, batchsize);
[~, predictedtraininglabels] = max(P);
trainerr = sum(predictedtraininglabels~=traininglabels)/ length(traininglabels); % training error
fprintf('train accuracy = %f, test accuracy = %f\n', 1-trainerr, 1-testerr);


svmparams  = params(1:(netconfig.xsize+1)*(netconfig.ysize));
convparams = params(1+(netconfig.xsize+1)*(netconfig.ysize):end);
stack = params2cstack(convparams, netconfig);
filename = '../models/classifier_cnn';
save(filename, 'trainerr', 'testerr', 'times','netconfig','stack', 'params', 'svmparams','cstack', 'lambda','-v7.3');
