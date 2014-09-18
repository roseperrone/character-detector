% Code written by Tao Wang (http://cs.stanford.edu/people/twangcat/)
% get SVT ground truth struct
function [trainStruct, testStruct] = getSVTStruct(drawBbox)

if ~exist('drawBbox', 'var')
    drawBbox = false;
end
addpath('svt1');
if ~exist('structs/svtWholeTestStruct.mat','file')
    svt_test_struct = parseXML('svt1/test.xml');
    jj = 1;
    for i = 2:2:498
        imgname = svt_test_struct.Children(i).Children(2).Children.Data;
        lex = textscan( svt_test_struct.Children(i).Children(6).Children.Data, '%s', 'Delimiter', ',');
        testStruct(jj).lex = lex{1};
        testStruct(jj).imgname = imgname;
        
        for kk = 2:2:length(svt_test_struct.Children(i).Children(10).Children)-1
            bb = kk/2;
            testStruct(jj).bbox(bb).trueTag = char(svt_test_struct.Children(i).Children(10).Children(kk).Children(2).Children.Data);
            h = str2double(svt_test_struct.Children(i).Children(10).Children(kk).Attributes(1).Value);
            w = str2double(svt_test_struct.Children(i).Children(10).Children(kk).Attributes(2).Value);
            x = str2double(svt_test_struct.Children(i).Children(10).Children(kk).Attributes(3).Value);
            y = str2double(svt_test_struct.Children(i).Children(10).Children(kk).Attributes(4).Value);
            testStruct(jj).bbox(bb).h = h;
            testStruct(jj).bbox(bb).w = w;
            testStruct(jj).bbox(bb).x = x;
            testStruct(jj).bbox(bb).y = y;
        end
        jj=jj+1;
    end
    save('structs/svtWholeTestStruct.mat', 'testStruct','-v7.3');
else
    load structs/svtWholeTestStruct.mat;
end



if ~exist('structs/svtWholeTrainStruct.mat','file')
    svt_train_struct = parseXML('train.xml');
    jj = 1;
    for i = 2:2:200
        
        imgname = svt_train_struct.Children(i).Children(2).Children.Data;
        lex = textscan( svt_train_struct.Children(i).Children(6).Children.Data, '%s', 'Delimiter', ',');
        trainStruct(jj).lex = lex{1};
        trainStruct(jj).imgname = imgname;
        
        for kk = 2:2:length(svt_train_struct.Children(i).Children(10).Children)-1
            bb = kk/2;
            trainStruct(jj).bbox(bb).trueTag = char(svt_train_struct.Children(i).Children(10).Children(kk).Children(2).Children.Data);
            h = str2double(svt_train_struct.Children(i).Children(10).Children(kk).Attributes(1).Value);
            w = str2double(svt_train_struct.Children(i).Children(10).Children(kk).Attributes(2).Value);
            x = str2double(svt_train_struct.Children(i).Children(10).Children(kk).Attributes(3).Value);
            y = str2double(svt_train_struct.Children(i).Children(10).Children(kk).Attributes(4).Value);
            trainStruct(jj).bbox(bb).h = h;
            trainStruct(jj).bbox(bb).w = w;
            trainStruct(jj).bbox(bb).x = x;
            trainStruct(jj).bbox(bb).y = y;
        end
        jj=jj+1;
    end
    save('structs/svtWholeTrainStruct.mat', 'trainStruct','-v7.3');
else
    load svtWholeTrainStruct.mat;
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
            bb = [max(y,1), min(x+w-1, width)];
            cc = [min(y+h-1, height), max(x,1)];
            dd = [min(y+h-1, height), min(x+w-1, width)];
            im(aa(1):cc(1), aa(2), 1) =  255;
            im(bb(1):dd(1), bb(2), 1) =  255;
            im(aa(1), aa(2):bb(2), 1) =  255;
            im(cc(1), cc(2):dd(2), 1) =  255;
        end
        imshow(im);
        pause;
    end
    
    for i = 1:length(testStruct)
        im = imread(testStruct(i).imgname);
        
        [height, width, depth] = size(im);
        for j = 1:length(testStruct(i).bbox)
            h = testStruct(i).bbox(j).h;
            w = testStruct(i).bbox(j).w;
            x = testStruct(i).bbox(j).x;
            y = testStruct(i).bbox(j).y;
            aa = [max(y,1),max(x,1)];
            bb = [max(y,1), min(x+w-1, width)];
            cc = [min(y+h-1, height), max(x,1)];
            dd = [min(y+h-1, height), min(x+w-1, width)];
            im(aa(1):cc(1), aa(2), 1) =  255;
            im(bb(1):dd(1), bb(2), 1) =  255;
            im(aa(1), aa(2):bb(2), 1) =  255;
            im(cc(1), cc(2):dd(2), 1) =  255;
        end
        imshow(im);
        pause;
    end   
end
