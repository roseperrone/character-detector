function runDetectorFull(dataset, num2ndLayerUnits)
% computes the line-level bounding boxes on full images using a character
% detector model. This is very slow so we recommend using our precomputed
% bounding boxes provided on the website. If you would like to compute the
% bboxes on your own, we recommend distributing the images to many machines
% in order to speed up the process. For a simpler demo, look at
% runDetectorDemo.m

if ~exist('num2ndLayerUnits', 'var')
    num2ndLayerUnits=256;
end
modelName = sprintf('models/CNN-B%d.mat', num2ndLayerUnits);
addpath(genpath('../finetune'));
load models/detectorCentroids_96.mat % 1st layer kmeans centroids
load(modelName)


fprintf('Constructing filter stack...\n');
filterStack = cstackToFilterStack(params, netconfig, centroids, P, M, [2,2,num2ndLayerUnits]);

addpath ../.
switch dataset
    case 'icdarTrain', 
        out_dir = '../precomputedLineBboxes/ICDARTrain/';
        system(['mkdir ' out_dir 'apanar_06.08.2002']);
	system(['mkdir ' out_dir 'lfsosa_12.08.2002']);
	system(['mkdir ' out_dir 'ryoungt_03.09.2002']);
	system(['mkdir ' out_dir 'ryoungt_05.08.2002']);
        data_dir = '../SceneTrialTrain/';
    case 'icdarTest',
        out_dir = '../precomputedLineBboxes/ICDARTest/';
	
	system(['mkdir ' out_dir 'ryoungt_05.08.2002']);
	system(['mkdir ' out_dir 'ryoungt_13.08.2002']);
	system(['mkdir ' out_dir 'sml_01.08.2002']);
        data_dir = '../SceneTrialTest/';
    case {'svtTest', 'svtTrain'},
        out_dir = '../precomputedLineBboxes/SVT/';	
	system(['mkdir ' out_dir 'img']);
        data_dir = '../svt1/';
    otherwise,
        error(['Unknown dataset: ', dataset]);
end
imgNames = getImgNames(dataset);

for i = 1:length(imgNames)
    img = imread([data_dir, imgNames{i}]);
    saveName = [out_dir, imgNames{i}];
    saveName(end-3:end)='.mat';
    fprintf('bbox filename is %s\n', saveName);
    if ~exist(saveName,'file') % only recompute if file does not exist
        fprintf('Computing responses...for img %s\n', [data_dir, imgNames{i}]);
        responses = computeResponses(img, filterStack);
        
        fprintf('Finding lines...\n');
        response = findBoxesFull(responses);
        fprintf('saving to %s\n', saveName);
        save(saveName, 'response');
    end
    
end
