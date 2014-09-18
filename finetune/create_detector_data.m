function [trainX, trainY, testX, testY, numlabels] = create_detector_data(CV)

fprintf('loading data\n');
load('../detectorTrain_1st_layer_features.mat');
features1 = features;
y1 = y(:);

load('../detectorCV_1st_layer_features.mat');
features2 = features;
y2 = y(:);

if CV % cross validation
    trainX = features1; trainY = y1';
    testX = features2; testY = y2';
else % actual training
    trainX = [features1; features2];
    trainY = [y1;y2];
    % test data is dummy in this case.
    testX = features1(1,:);
    testY = y1(1);
end

numlabels = max(trainY);
fprintf('sphereing data\n');
counts = size(trainX,1);
sums = sum(trainX);
sumSqrs = sum(trainX.^2);
mu = sums / counts;
sig = sqrt((sumSqrs - sums.^2 / counts) / (counts-1) + 0.01);
if ~CV
    save('detector_sig_mu.mat', 'mu', 'sig');
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

