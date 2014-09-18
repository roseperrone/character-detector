function runDetectorDemo(outputDir)

addpath(genpath('../finetune'));

% load first layer features
load models/detectorCentroids_96.mat
% load detector model
load models/CNN-B64.mat
img = imread('models/sampleImage.jpg');

fprintf('Constructing filter stack...\n');
filterStack = cstackToFilterStack(params, netconfig, centroids, P, M, [2,2,64]);

fprintf('Computing responses...\n');
responses = computeResponses(img, filterStack);

fprintf('Finding lines...\n');
boxes = findBoxesFull(responses);

visualizeBoxes(img, boxes);

if exist('outputDir')
  system(['mkdir -p ', outputDir]);
  save([outputDir, '/output.mat'], 'filterStack', 'responses', 'boxes', '-v7.3');
end
