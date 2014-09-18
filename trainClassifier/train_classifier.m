%% train first layer filters with kmeans
if ~exist('../kmeans/first_layer_centroids.mat', 'file') 
    addpath(genpath('../kmeans/'));
    kmeansDemo;
else
    load ../kmeans/first_layer_centroids.mat;
end

%% extract first layer features
addpath('../extract1stLayerFeatures/');
createFeatures('icdarTrain', '../kmeans/first_layer_centroids.mat');
createFeatures('icdarSample', '../kmeans/first_layer_centroids.mat');
createFeatures('icdarTest', '../kmeans/first_layer_centroids.mat');

%% finetuning
addpath(genpath('../finetune/'));
convnet_wrapper_svm_fix1stlayer;

