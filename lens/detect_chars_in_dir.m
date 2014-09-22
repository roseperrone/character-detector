% This script runs the character detector over all images in `SRC` and
% outputs to `DST` information about which image patches are predicted to
% contain a charaacter.
%
% To visualize the patches that contain detected characters,
% run show_detected_char_boxes.py.
%
% This could be sped up with the use of a GPU.


% The following is the training set. The character detector should work
% well on it.
SRC = '/Users/rose/iodine/lens/data/july-28-grabcut-rotated/';

%SRC = '/Users/rose/iodine/lens/data/sep-11-train/';
DST = 'data/predicted_chars.csv';

addpath(genpath('../detectorDemo'));
addpath(genpath('../finetune'));

all_files = dir(SRC);
% Removes the first three files, which are ., .., and .DS_Store
files = all_files(4:size(all_files, 1));
filenames = cell(1, size(files, 1));
for i = 1:size(files, 1)
   filenames(i) = {files(i).name};
end

% Load the neural net
load('../models/detector_cnn.mat')

% The filters of the first layer
filters = struct('w', centroids, 'fx', 8, 'fy', 8, 'fs', 1, 'fch', 1, 'P', P, 'M', M, ...
     'px', 5, 'py', 5, 'ps', 5, 'poolfunc', @meanpool);

f = fopen(DST, 'a+');
count = 0;

done_filenames = csvimport(DST, 'columns', [1], 'outputAsChar', true, ...
                           'noHeader', true, 'uniformOutput', false);

for i = 1:size(filenames, 2)
    filename = filenames(i);
    if sum(ismember(done_filenames, strcat(SRC, filename{1}))) == 0
        img = imread(strcat(SRC, filename{1}));
        predictions = detect_chars(img, params, netconfig, filters);
        if size(predictions, 2) == 1
            fprintf(f, '%s\n', strcat(SRC, filename{1}));
        else
            for prediction = predictions
                count = count + 1;
                fprintf(f, '%s,%d,%d,%d\n', strcat(SRC, filename{1}), prediction.x, ...
                    prediction.y, prediction.size);
            end
        end
    end
end

disp(strcat(num2str(count), ' chars were detected'))
fclose(f);