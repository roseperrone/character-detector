% Code written by Tao Wang (http://cs.stanford.edu/people/twangcat/)
% reproducing cropped word recognition results
addpath(genpath('.'));
model = loadRecognitionModel; % load recognizer model
D1 = model.D;
M1 = model.M;
P1 = model.P;
mu = model.mu;
sig = model.sig;
params = model.params;
netconfig = model.netconfig;

benchMark = 'icdar'; % change to 'svt' if test on svt
global c_std c_narrow;
if strcmp(benchMark,'icdar') % icdar word recognition benchmark
    % load ground truth info
    tagStruct = parseXML('word/word.xml');
    lextype='full'; % change to '50' if testing on icdar-word-50
    if strcmp(lextype,'full')
        % construct 'full' lexicon
        fullLex = [];
        for imIdx = 2:2:length(tagStruct.Children)
            origtag = tagStruct.Children(imIdx).Attributes(2).Value;
            origtag = regexprep(char(origtag),'[^a-zA-Z0-9]','');
            if length(origtag)>2
                fullLex{end+1} = origtag;
            end
        end
    end
    
    
    [testStruct, ~] = getIcdarTestStruct;
    % if score is already precomputed, don't have to do it again
    if exist('structs/icdarTestWordScoreStruct.mat', 'file')
        load structs/icdarTestWordScoreStruct.mat;
        computeScore = false;
    else
        computeScore = true;
    end
    
    % hyperparameters found by grid search on training sets
    c_std = 0.08;
    c_narrow = 0.6;
    
    fullImgIdx = 1; % index of the full image from which the word is cropped
    bboxCnt = 0;
    totalStrings = 0;
    totalCorrect = 0;
    for imIdx = 2:2:length(tagStruct.Children)
        trueTag =  tagStruct.Children(imIdx).Attributes(2).Value;
        if length(trueTag)>2&& sum(  isstrprop(trueTag, 'alphanum'))==length(trueTag)
            trueTag = trueTag( isstrprop(trueTag,'alpha') | isstrprop(trueTag,'digit'));
            if computeScore
                imgname =  tagStruct.Children(imIdx).Attributes(1).Value;
                imgname = ['word' imgname(5:end)];
                disp([num2str(imIdx) '/' num2str(length(tagStruct.Children)) '   ' imgname])
                im = imread(imgname);
                img = rgb2gray(im);
                icdarTestWordScoreStruct(imIdx).scores = getRecogScores_convnet(img, D1, M1, P1, mu,sig, params, netconfig);
            end
            scores = icdarTestWordScoreStruct(imIdx).scores;
            
            if strcmp(lextype,'50') && fullImgIdx<=length(testStruct) % get lexicon for current word
                lexfile = ['icdarTestLex/lex50/I00'];
                tmpstr = num2str(fullImgIdx-1);
                num0s = 3-length(tmpstr);
                lexfile = [lexfile, repmat(['0'], 1, num0s), tmpstr, '.jpg.txt'];
                fid = fopen(lexfile,'r');
                str = textscan(fid, '%s');
                lex = str{1};
                fclose(fid);
            elseif strcmp(lextype,'full') || fullImgIdx>length(testStruct) 
                % no lex-50 files are given for the last 3 word imgs. use full lexicon in that case
                lex = fullLex;
            else
                error('unknow lexicon type');
            end
            
            
            
            [predword, bestdist, matchScore, bounds] = score2Word(scores, lex);
            
            if strcmpi(predword, trueTag) % ignore case
                totalCorrect = totalCorrect+1;
            end
            totalStrings = totalStrings+1;
            
            disp(['true label: ' trueTag ',  predicted label: ' predword ',  accuracy so far: '  num2str(totalCorrect)  '/' num2str(totalStrings)]);
        end
        bboxCnt = bboxCnt+1;
        % procede to next full image if necessary, so we know which lex file to
        % use
        if fullImgIdx<=length(testStruct) && bboxCnt == length(testStruct(fullImgIdx).bbox)
            fullImgIdx = fullImgIdx+1;
            bboxCnt = 0;
        end
    end
    if computeScore
        save structs/icdarTestWordScoreStruct.mat icdarTestWordScoreStruct
    end
    accuracy = totalCorrect/totalStrings
% test on svt word benchmark
elseif strcmp(benchMark,'svt')
    if exist('structs/svtTestWordScoreStruct.mat', 'file')
        load structs/svtTestWordScoreStruct.mat;
        computeScore = false;
    else
        computeScore = true;
    end
    
    % load ground truth
    load structs/svtWordTestStruct.mat
    % hyperparameters found by grid search on training sets
    c_std= 0.14;
    c_narrow = 0.6;
    totalStrings = 0;
    totalCorrect = 0;
    for imIdx = 1:length(testStruct)
        trueTag =  testStruct(imIdx).trueTag;
        disp(['image ' num2str(imIdx) '/' num2str(length(testStruct))])
        if length(trueTag)>2&& sum(  isstrprop(trueTag, 'alphanum'))==length(trueTag)
            trueTag = trueTag( isstrprop(trueTag,'alpha') | isstrprop(trueTag,'digit'));
            im = testStruct(imIdx).img;
            lex = testStruct(imIdx).lexicon;
            
            if computeScore
                img = rgb2gray(im);
                svtTestWordScoreStruct(imIdx).scores = getRecogScores_convnet(img, D1, M1, P1, mu,sig, params, netconfig);
            end
            
            scores = svtTestWordScoreStruct(imIdx).scores;
            [predword, bestdist, matchScore, bounds] = score2Word(scores, lex);
            
            if strcmpi(predword, trueTag)
                totalCorrect = totalCorrect+1;
            end
            totalStrings = totalStrings+1;
            
           disp(['true label: ' trueTag ',  predicted label: ' predword ',  accuracy so far: '  num2str(totalCorrect)  '/' num2str(totalStrings)]);
        end
    end
    if computeScore
        save structs/svtTestWordScoreStruct.mat svtTestWordScoreStruct
    end
    accuracy = totalCorrect/totalStrings;
else
    error('unknown benchmark');
end

