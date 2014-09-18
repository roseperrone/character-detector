%% train first layer filters with kmeans
if ~exist('../kmeans/first_layer_centroids_detector_48.mat', 'file')
    
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
    load('../dataset/Icdar.Train.Robust.all.mat', 'e');
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

trainDataFile='../dataset/detectorTrain.mat';
cvDataFile='../dataset/detectorCV.mat';
maxIter=150;
% train CNN model for detector using backprop
addpath ../detectorDemo/
trainDetectorCNN(trainDataFile, cvDataFile, D, P, M, maxIter);


