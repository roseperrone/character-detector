% Code written by Tao Wang (http://cs.stanford.edu/people/twangcat/)

function [trainStruct, icdarTrainLex] = getIcdarTrainStruct(drawBbox)
if ~exist('drawBbox', 'var')
    drawBbox = false;
end
addpath SceneTrialTrain/;
if ~exist('structs/icdarWholeTrainStruct.mat','file');
    addpath('../')
    icdar_train_struct = parseXML('SceneTrialTrain/words.xml');
    
    jj = 1;
    icdarTrainLex = {};
    for i = 2:2:length(icdar_train_struct.Children)-1
        imgname = icdar_train_struct.Children(i).Children(2).Children.Data;
        %lex = textscan( icdar_train_struct.Children(i).Children(6).Children.Data, '%s', 'Delimiter', ',');
        %trainStruct(jj).lex = lex{1};
        trainStruct(jj).imgname = imgname;
        trainStruct(jj).height =  icdar_train_struct.Children(i).Children(4).Attributes(2);
        trainStruct(jj).width = icdar_train_struct.Children(i).Children(4).Attributes(1);
        for kk = 2:2:length(icdar_train_struct.Children(i).Children(6).Children)-1
            bb = kk/2;
            trainStruct(jj).bbox(bb).trueTag = upper(char(icdar_train_struct.Children(i).Children(6).Children(kk).Children(2).Children.Data));
            wordExists=0;
            for ll = 1:length(icdarTrainLex)
                if strcmp(char(icdarTrainLex{ll}), trainStruct(jj).bbox(bb).trueTag)
                    wordExists = 1;
                end
            end
            if wordExists ==0
                icdarTrainLex{end+1} = trainStruct(jj).bbox(bb).trueTag;
            end
            
            
            h = str2double(icdar_train_struct.Children(i).Children(6).Children(kk).Attributes(1).Value);
            w = str2double(icdar_train_struct.Children(i).Children(6).Children(kk).Attributes(5).Value);
            offset = str2double(icdar_train_struct.Children(i).Children(6).Children(kk).Attributes(2).Value);
            x = str2double(icdar_train_struct.Children(i).Children(6).Children(kk).Attributes(6).Value);
            y = str2double(icdar_train_struct.Children(i).Children(6).Children(kk).Attributes(7).Value);
            trainStruct(jj).bbox(bb).h = h;
            trainStruct(jj).bbox(bb).w = w;
            trainStruct(jj).bbox(bb).x = x;
            trainStruct(jj).bbox(bb).y = y;
        end
        jj=jj+1;
    end
    save('structs/icdarWholeTrainStruct.mat', 'trainStruct', 'icdarTrainLex','-v7.3');
else
    load structs/icdarWholeTrainStruct.mat;
end


if drawBbox
    for i = 1:length(trainStruct)
        im = imread(trainStruct(i).imgname);
        %draw bounding boxes
        % aa---------------bb
        %  |                |
        %  |                |
        %  |                |
        %  cc--------------dd
        [height, width, depth] = size(im);
        for j = 1:length(trainStruct(i).bbox)
            h = trainStruct(i).bbox(j).h;
            w = trainStruct(i).bbox(j).w;
            x = trainStruct(i).bbox(j).x;
            y = trainStruct(i).bbox(j).y;
            aa = [max(y,1),max(x,1)];
            bb = [max(y,1), min(x+w, width)];
            cc = [min(y+h, height), max(x,1)];
            dd = [min(y+h, height), min(x+w, width)];
            im(aa(1):cc(1), aa(2), 1) =  255;
            im(bb(1):dd(1), bb(2), 1) =  255;
            im(aa(1), aa(2):bb(2), 1) =  255;
            im(cc(1), cc(2):dd(2), 1) =  255;
        end
        imshow(im);
        pause;
    end
end
