% Code written by Tao Wang (http://cs.stanford.edu/people/twangcat/)
% demo of end-to-end text recognition using trained character detector and recognizer
% models, and reproduce the end-to-end results reported in the paper
addpath(genpath('.'));
model = loadRecognitionModel; % load recognizer model

% load dataset info
[icdarTrainStruct, icdarTrainLex] = getIcdarTrainStruct;
[icdarTestStruct, icdarTestLex] = getIcdarTestStruct;
[svtTrainStruct, svtTestStruct] = getSVTStruct;
% lexicon type used for the icdar dataset
lextype = 'full'; % replace with '5', '20' or '50' for dfferent lex sizes

% hyperparameters obtained with grid search on icdarTrain

std_cost = 0.21; narrow_cost = 0.2; split_cost = 4; 
% these are the thresholds that give best fscores
switch lextype
    case 'full',
        THRESH=0.2;
    case '5',
        THRESH=-1.1;
    case '20',
        THRESH=-0.7;
    case '50',
        THRESH=-0.3;
end
% test on icdar dataset
[icdar_precision, icdar_recall, icdar_fscore] = getFScore('icdarTest',model, icdarTestStruct, icdarTestLex, std_cost, narrow_cost, split_cost, lextype,THRESH);

% hyperparameters obtained with grid search on svtTrain
std_cost = 0.12; narrow_cost = 0.3; split_cost = 4; 
% this is the threshold that gives best fscore
THRESH=0.2;
% test on svt dataset
[svt_precision, svt_recall, svt_fscore] = getFScore('svtTest', model, svtTestStruct, {}, std_cost, narrow_cost, split_cost, lextype, THRESH);

