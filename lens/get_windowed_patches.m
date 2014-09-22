function [ patches, window_info ] = get_windowed_patches( img )
%GET_WINDOWED_PATCHES Returns all the patches found in sliding windows
%   window_info is an array of structs that each have these fields:
%     x, y, size
%   where (x, y) is the top left corner of the window, and `size` is the
%   image size from which the 32x32 patch was cropped.
%   We generate all the patches at once so we can batch the neural net predictions. 
%   `img` is a gray 512x512 image

LESS_WINDOWS = false; % Whether to reduce the number of patches produced
                      % to speed up character detection.

if LESS_WINDOWS
    img_sizes = [512, 256, 128, 64];
    step_sizes = [16, 16, 8, 8];
else
    img_sizes = [1024, 512, 256, 128, 64];
    step_sizes = [16, 16, 8, 8, 8];
end

w = 32; % the window size

patches = [];
window_info = [];
num_patches = 0;

for i=1:size(img_sizes, 2)
    t = img_sizes(i);
    s = step_sizes(i);
    img = imresize(img, [t t]);
    for k=1:((t-w)/s + 1)
        for j=1:((t-w)/s + 1)           
            x = 1 + (k-1)*s;
            y = 1 + (j-1)*s;
            patch_mat = img(x:(x+w-1), y:(y+w-1));
            patch = mat2gray(patch_mat);
            if patch_is_on_pill(patch)
                num_patches = num_patches + 1;
                patches(:, :, num_patches) = 255*patch;
                window_info = [window_info; struct('x', x, 'y', y, 'size', t)];
            end
        end
    end
end

disp(size(patches))

end