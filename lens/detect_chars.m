function predictions = detect_char( img, netparams, netconfig, filters )
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

nFilters = size(filters.w, 1);
batchSize = 500;

[patches, window_info] = get_windowed_patches(rgb2gray(img));
predictions = [];

first_layer_responses = firstLayerFeatures(patches, filters);
N = size(first_layer_responses, 2);
X = zeros(5, 5, nFilters, N);
for i=1:N
    X(:,:,:,i) = reshape(first_layer_responses(:,i), 5, 5, nFilters);
end
pred = svmConvPredict(netparams, netconfig, X, batchSize);
[~, predicted] = max(pred);
for i=1:size(predicted, 2)
    if predicted(i) == 1
        disp(window_info(i))
        predictions = [predictions window_info(i)]
    end
end

end

