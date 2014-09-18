%% this script extracts patches from training examples,
% then trains a set of filters using the dot-product variant of K-means


%% set up constants
ht = 32; % training image height and width
wd = 32;
n_pat = 8;	 % number of patches from each image
sz = 8; % filter and patch size
n_filters = 150; % number of initial filters to train
n_iter = 500; % maximum number of kmeans iterations to run

%%  load training examples and extract patches

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
%% train filters
% normalize for contrast and then perform ZCA whiten
[patches M P] = normalizeAndZCA(patches);
%Uses dot-product Kmeans to learn a specified number of bases.
D = run_projection_kmeans(patches,n_filters,n_iter);	

%% discard filters with low variance, then visualize
varthresh = 0.025;
newD = selectCentroids(D, varthresh);
display_network(newD'); % uncomment to visualize learnt features
D = newD;
save('first_layer_centroids.mat','D','M','P', '-v7.3');
