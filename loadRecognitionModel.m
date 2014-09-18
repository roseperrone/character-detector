% Code written by Tao Wang (http://cs.stanford.edu/people/twangcat/)
% load our best character recognition model

function model = loadRecognitionModel

load models/best_centroids.mat;
model.D = D; % first layer filters
model.M = M; % whitening parameters
model.P = P;

load models/best_classifier_convnet.mat;
netconfig.stackinfo{1}.actfunc = @triangleRect;
netconfig.stackinfo{1}.actfuncg = @triangleRectGrad;
model.netconfig = netconfig; % neural network structure
model.params = params; % linearized network weights

load models/best_classifier_sig_mu.mat mu sig;
model.mu = mu; % params for normalizing 1st layer response
model.sig = sig;

