% Usage:
%  Set USE_EXISTING_CLUSTERS to 1 if you don't want to rerun k-means to
%  create the neural net's first layer of filters.
%  Set USE_LENS_DATA to 0 if you want to use the default data for the
%  detector demo. Set this flag to 1 if you want to use data generated
%  from pill images.
% TODO make this set of positive characters not contain characters from
%      the train and test sets.
USE_EXISTING_CLUSTERS = 1;
USE_LENS_DATA = 1;

%% train first layer filters with kmeans
if USE_LENS_DATA
    all_positive_chars_file = '../lens/data/positive_char_patches.mat';
    trainDataFile='../dataset/detectorTrain.mat';
    cvDataFile='../dataset/detectorCV.mat';
else
    all_positive_chars_file = '../dataset/Icdar.Train.Robust.all.mat';
    trainDataFile='../lens/data/train_char_patches.mat';
    cvDataFile='../lens/data/test_char_patches.mat';
end

if USE_EXISTING_CLUSTERS == 1 & ~exist('../kmeans/first_layer_centroids_detector_48.mat', 'file')
    addpath(genpath('../kmeans/'));
    % set up constants
    ht = 32; % training image height and width
    wd = 32;
    n_pat = 8;	 % number of patches from each image
    sz = 8; % filter and patch size
    n_filters = 48; % number of initial filters to train
    n_iter = 400; % maximum number of kmeans iterations to run
    
    %  load training examples and extract patches for kmeans training.
    %  Note that here we use the icdar train dataset  which only contain
    %  positives.

    load(all_positive_chars_file, 'e');
    e.img = double(e.img);
    N = size(e.img,3); % number of training examples
    patches = zeros( N*n_pat, sz*sz );
    cnt = 1;
    while(cnt ~= N * n_pat )
        k = ceil(rand(1) * (N-1)) + 1;
        ypos = ceil(rand(1) * (ht-sz-1) ) + 1;
        xpos = ceil(rand(1) * (wd-sz-1) ) + 1;
        img = e.img(ypos:ypos+sz-1,xpos:xpos+sz-1,k);
        img = img(:);
        patches(cnt,:) = img';
        cnt = cnt + 1;
    end
    % train filters
    % normalize for contrast and then perform ZCA whiten
    [patches M P] = normalizeAndZCA(patches);
    %Uses dot-product Kmeans to learn a specified number of bases.
    D = run_projection_kmeans(patches,n_filters,n_iter);
    save('../kmeans/first_layer_centroids_detector_48.mat','D','M','P', '-v7.3');
else
    load ../kmeans/first_layer_centroids_detector_48.mat;
end

maxIter=150;
% train CNN model for detector using backprop
addpath ../detectorDemo/
trainDetectorCNN(trainDataFile, cvDataFile, D, P, M, maxIter);


