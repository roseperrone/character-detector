function [ patches, window_info ] = get_windowed_patches( img )
%GET_WINDOWED_PATCHES Returns all the patches found in sliding windows
%   We generate all the patches at once so we can batch the neural net predictions. 
%   img is a gray 32x32 image

img_sizes = [512, 256, 128, 64]; % TODO 1024
%step_sizes = [16, 16, 8, 8, 8];
w = 32; % the window size

patches = [];
window_info = [];
num_patches = 0;

for i=1:size(img_sizes, 2)
    t = img_sizes(i);
    %s = step_sizes(i);   
    s = 16;
    img = imresize(img, [t t]);
    for k=1:((t-w)/s + 1)
        for j=1:((t-w)/s + 1)           
            x = 1 + (k-1)*s;
            y = 1 + (j-1)*s;
            patch_mat = img(x:(x+w-1), y:(y+w-1));
            patch = mat2gray(patch_mat, [0 255]); % TODO should 255 be 1?
            if patch_is_on_pill(patch)
                num_patches = num_patches + 1;
                patches(:, :, num_patches) = patch;
                window_info = [window_info; struct('x', x, 'y', y, 'scale', t)];
            end
        end
    end
end

disp(size(patches))

end

