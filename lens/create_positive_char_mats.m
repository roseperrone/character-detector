%% Loads the jpgs into a struct of matrices that the detector demo uses.
POSITIVE_CHAR_PATCHES_DIR = 'data/positive-chars-sep-19';
POSITIVE_CHAR_PATCHES_OUPUT_FILE = 'data/positive_char_patches.mat';

PATCH_SIZE = 32;

all_files = dir(POSITIVE_CHAR_PATCHES_DIR);
% Removes the first three files. They're ., .., and .DS_Store
files = all_files(4:size(all_files));
imgs = zeros(PATCH_SIZE, PATCH_SIZE, size(files, 1));

for j = 1:size(files, 1)
    img = imread(strcat(POSITIVE_CHAR_PATCHES_DIR, '/', files(j).name), 'jpg');
    imgs(:, :, j) = img;
end

e = struct('img', imgs);
save(POSITIVE_CHAR_PATCHES_OUPUT_FILE, 'e');

