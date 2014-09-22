function predictions = detect_char( img, netparams, netconfig, filters )
%DETECT_CHAR Detects characters
%   Returns an array of structs, where each struct has these fields:
%     filename: the input filename
%     x, y: the top left corner of the detected char
%     size: the image size at which the character was detected

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
% If all the prediction scores are the same, make sure the input patches
% have values in the range 0-255 rather than 0-1.
[~, predicted] = max(pred);

for i=1:size(predicted, 2)
    if predicted(i) == 1
        predictions = [predictions window_info(i)];
    end
end

end

