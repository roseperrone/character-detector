function imgNames = getImgNames(dataset)
addpath ../.

switch dataset
    case 'icdarTrain', 
        xml_struct = parseXML('../SceneTrialTrain/words.xml');
    case 'icdarTest',
        xml_struct = parseXML('../SceneTrialTest/words.xml');
    case {'svtTrain'}
        xml_struct = parseXML('../svt1/train.xml');
    case {'svtTest'},
        xml_struct = parseXML('../svt1/test.xml');
    otherwise,
        error(['Unknown dataset: ', dataset]);
end
jj = 1;
imgNames = {};
for i = 2:2:length(xml_struct.Children)-1
    imgname = xml_struct.Children(i).Children(2).Children.Data;
    imgNames{jj} = imgname;
    jj=jj+1;
end


