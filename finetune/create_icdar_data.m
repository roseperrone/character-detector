function [trainX, trainY, testX, testY, numlabels] = create_icdar_data(CV)

fprintf('loading train data\n');
features1 = []; y1 = [];
load('IcdarTrain_1stlayer_features.mat');
features1 = [features1; features];
y1 = [y1; y(:)];

load('IcdarSample_1stlayer_features.mat');
features1 = [features1; features];
y1 = [y1;y(:)];

if CV % cross validation
    randidx = randperm(length(y1));
    trainX = features1(randidx(1:5000),:); trainY = y1(randidx(1:5000))';
    testX = features1(randidx(5000:end),:); testY = y1(randidx(5000:end))';
    clear features1;
else % actual training
    trainX = features1; trainY = y1(:)';
    clear features1;
    fprintf('loading test data\n');
    load('IcdarTest_1stlayer_features.mat');
    testX = features;
    testY =y(:)';
end

nChar = max(trainY);
fprintf('sphereing data\n');
counts = size(trainX,1);
sums = sum(trainX);
sumSqrs = sum(trainX.^2);
mu = sums / counts;
sig = sqrt((sumSqrs - sums.^2 / counts) / (counts-1) + 0.01);
if ~CV
    save('../models/sig_mu.mat', 'mu', 'sig');
end
trainX = bsxfun(@rdivide, bsxfun(@minus, trainX, mu), sig)';
testX = bsxfun(@rdivide, bsxfun(@minus, testX, mu), sig)';

imh = 5; imw = 5; [imd_full imm]=size(trainX);
imd = imd_full/(imh*imw);
trainX = reshape(trainX, [imd, imw, imh, imm]); 
trainX = permute(trainX, [3,2,1,4]);

imh = 5; imw = 5; [imd_full imm]=size(testX);
imd = imd_full/(imh*imw);
testX = reshape(testX, [imd, imw, imh, imm]); 
testX = permute(testX, [3,2,1,4]);

numlabels = nChar;
