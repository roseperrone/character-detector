function createFeatures(dataset, filterFile)
addpath ../kmeans
load(filterFile, 'D', 'M', 'P');

switch dataset
    case 'icdarTrain',
        dataFile = '../dataset/Icdar.Train.Robust.all.mat';
        saveFile = 'IcdarTrain_1stlayer_features.mat';
        useASCII = true;
    case 'icdarTest',
        dataFile = '../dataset/Icdar.Test.all.mat';
        saveFile = 'IcdarTest_1stlayer_features.mat';
        useASCII = true;
    case 'icdarSample',
        dataFile = '../dataset/Icdar.Sample.mat';
        saveFile = 'IcdarSample_1stlayer_features.mat';
        useASCII = true;
    case 'detectorTrain'
        dataFile = '../dataset/detectorTrain.mat';
        saveFile = 'detectorTrain_1st_layer_features.mat';
        useASCII = false;
    case 'detectorCV'
        dataFile = '../dataset/detectorCV.mat';
        saveFile = 'detectorCV_1st_layer_features.mat';
        useASCII = false;
    otherwise,
        error(['Unknown dataset: ', dataset]);
end

features = [];
load(dataFile,'e');
e.img = double(e.img);
for quad = 1:25
    fprintf('train data quadrant %d\n', quad);
    [data, y] = prepData(e,quad,useASCII, M, P);
    features = [features, extractFeatures(D,data,length(y),12*12)];
end
features = single(features);
size(features)
size(y)
save(saveFile,'features','y','-v7.3');
clear data;
clear e;



