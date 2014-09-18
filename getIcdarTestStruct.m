% Code written by Tao Wang (http://cs.stanford.edu/people/twangcat/)
% Get the ground truth of ICDAR 2003 testset into a matlab struct
function [testStruct, icdarTestLex] = getIcdarTestStruct(drawBbox)
if ~exist('drawBbox', 'var')
    drawBbox = false;
end
addpath SceneTrialTest/;
if ~exist('structs/icdarWholeTestStruct.mat','file');

    addpath('../')
    icdar_test_struct = parseXML('SceneTrialTest/words.xml');
    
    jj = 1;
    icdarTestLex = {};
    for i = 2:2:length(icdar_test_struct.Children)-1
        imgname = icdar_test_struct.Children(i).Children(2).Children.Data;
        %lex = textscan( icdar_test_struct.Children(i).Children(6).Children.Data, '%s', 'Delimiter', ',');
        %testStruct(jj).lex = lex{1};
        testStruct(jj).imgname = imgname;
        testStruct(jj).height =  icdar_test_struct.Children(i).Children(4).Attributes(2);
        testStruct(jj).width = icdar_test_struct.Children(i).Children(4).Attributes(1);
        for kk = 2:2:length(icdar_test_struct.Children(i).Children(6).Children)-1
            bb = kk/2;
            testStruct(jj).bbox(bb).trueTag = upper(char(icdar_test_struct.Children(i).Children(6).Children(kk).Children(2).Children.Data));
            wordExists=0;
            for ll = 1:length(icdarTestLex)
                if strcmp(char(icdarTestLex{ll}), testStruct(jj).bbox(bb).trueTag)
                    wordExists = 1;
                end
            end
            if wordExists ==0
                icdarTestLex{end+1} = testStruct(jj).bbox(bb).trueTag;
            end
            
            
            h = str2double(icdar_test_struct.Children(i).Children(6).Children(kk).Attributes(1).Value);
            w = str2double(icdar_test_struct.Children(i).Children(6).Children(kk).Attributes(5).Value);
            offset = str2double(icdar_test_struct.Children(i).Children(6).Children(kk).Attributes(2).Value);
            x = str2double(icdar_test_struct.Children(i).Children(6).Children(kk).Attributes(6).Value);
            y = str2double(icdar_test_struct.Children(i).Children(6).Children(kk).Attributes(7).Value);
            testStruct(jj).bbox(bb).h = h;
            testStruct(jj).bbox(bb).w = w;
            testStruct(jj).bbox(bb).x = x;
            testStruct(jj).bbox(bb).y = y;
        end
        jj=jj+1;
    end
    save('structs/icdarWholeTestStruct.mat', 'testStruct', 'icdarTestLex','-v7.3');
else
    load structs/icdarWholeTestStruct.mat;
end

if drawBbox
    for i = 1:length(testStruct)
        im = imread(testStruct(i).imgname);
        %draw bounding boxes
        % aa---------------bb
        %  |                |
        %  |                |
        %  |                |
        %  cc--------------dd
        [height, width, depth] = size(im);
        for j = 1:length(testStruct(i).bbox)
            h = testStruct(i).bbox(j).h;
            w = testStruct(i).bbox(j).w;
            x = testStruct(i).bbox(j).x;
            y = testStruct(i).bbox(j).y;
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
