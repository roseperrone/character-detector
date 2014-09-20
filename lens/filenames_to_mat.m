%% This script converts the jpgs referenced by `filenames` to a stack of matrices
% The `filenames` are basenames relative to the directory, `src`.

function imgs = filenames_to_mat(src, filenames)

imgs = zeros(32, 32, size(filenames, 2));

for i = 1:size(filenames, 2)
    filename = filenames(i);
    img = imread(strcat(src, '/', filename{1}), 'jpg');
    imgs(:, :, i) = img;
end
