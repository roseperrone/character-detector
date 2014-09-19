%% Loads the jpgs into a struct of matrices that the detector demo uses.

PATCH_SIZE = 32;
src = 'data/positive-chars-sep-19';
dst = 'data/positive_char_patches.mat';

all_files = dir(src);
% Removes the first three files. They're ., .., and .DS_Store
files = all_files(4:size(all_files));
imgs = zeros(PATCH_SIZE, PATCH_SIZE, size(files, 1));

for j = 1:size(files, 1)
    img = imread(strcat(src, '/', files(j).name), 'jpg');
    imgs(:, :, j) = img;
end

e = struct('img', imgs);
save(dst, 'e');

