function predictions = detect_char( filename, on_pill_percentage )
%DETECT_CHAR Detects characters
%   Returns an array of structs, where each struct has these fields:
%     filename: the input filename
%     x, y: the top left corner of the detected char
%     scale: the image scale at which the character was detected


% The window size is always 32x32
% The possible scales, and the window step sizes at each scale
% 1024  16
% 512   16
% 256   8
% 128   8
% 64    8
%
% So roughly 6.4k windows are computed. Let's see if this is too slow...

img = rgb2gray(imread(filename));
img_sizes = [64, 512, 256, 128, 64];
step_sizes = [16, 16, 8, 8, 8];

w = 32; % the window size

for i=1:size(img_sizes, 2)
    t = img_sizes(i);
    s = step_sizes(i);
    img = imresize(img, [t t]);
    for i=1:((t-w)/s + 1)
        for j=1:((t-w)/s + 1)
            x = 1 + (i-1)*s;
            y = 1 + (j-1)*s;
            patch_mat = img(x:(x+w-1), y:(y+w-1));
            patch = mat2gray(patch_mat, [0 255]);
            if patch_is_on_pill(patch, on_pill_percentage)
               disp('classify the patch')
            end
            % TODO filter the image if it has > 80% pixels that
            % are less than 15.
        end
    end
end

predictions = [];

predictions = [predictions; struct('filename', 'just/testing', ...
                                   'x', 3, ...
                                   'y', 4, ...
                                   'scale', 1.7203)];

end

