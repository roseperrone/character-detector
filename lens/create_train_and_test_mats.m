%% Loads the jpgs into a struct of matrices that the detector demo uses.

PATCH_SIZE = 32;
TRAIN_PERCENTAGE = 0.2;

all_positive_files = dir('data/positive-chars-sep-19');
all_negative_files = dir('data/negative-chars-sep-19');

% The first three files are ., .., and .DS_Store
positive_files_struct = all_positive_files(4:size(all_positive_files));
negative_files_struct = all_negative_files(4:size(all_negative_files));

positive_files = cell(1, size(positive_files_struct, 1));
for i=1:size(positive_files_struct, 1)
    positive_files(i) = {positive_files_struct(i).name};
end

negative_files = cell(1, size(negative_files_struct, 1));
for i=1:size(negative_files_struct, 1)
    negative_files(i) = {negative_files_struct(i).name};
end

[positive_train_idx, positive_test_idx] = crossvalind('HoldOut', size(positive_files, 2), TRAIN_PERCENTAGE);
[negative_train_idx, negative_test_idx] = crossvalind('HoldOut', size(negative_files, 2), TRAIN_PERCENTAGE);

train_classes = [ones(sum(positive_train_idx), 1); 2*ones(sum(negative_train_idx), 1)];
test_classes = [ones(sum(positive_test_idx), 1); 2*ones(sum(negative_test_idx), 1)];

% Make the train struct
positive_train_mat = filenames_to_mat('data/positive-chars-sep-19', positive_files(positive_train_idx));
negative_train_mat = filenames_to_mat('data/negative-chars-sep-19', negative_files(negative_train_idx));
num_pos = size(positive_train_mat, 3);
num_neg = size(negative_train_mat, 3);
train_mat = zeros(PATCH_SIZE, PATCH_SIZE, num_pos + num_neg);
train_mat(:,:,1:num_pos) = positive_train_mat;
train_mat(:,:,num_pos:(num_pos + num_neg - 1)) = negative_train_mat;
e = struct('img', train_mat, ...
           'class', train_classes);
save('data/train_char_patches.mat', 'e');

% Make the test struct
positive_test_mat = filenames_to_mat('data/positive-chars-sep-19', positive_files(positive_test_idx));
negative_test_mat = filenames_to_mat('data/negative-chars-sep-19', negative_files(negative_test_idx));
num_pos = size(positive_test_mat, 3);
num_neg = size(negative_test_mat, 3);
test_mat = zeros(PATCH_SIZE, PATCH_SIZE, num_pos + num_neg);
test_mat(:,:,1:num_pos) = positive_test_mat;
test_mat(:,:,num_pos:(num_pos + num_neg - 1)) = negative_test_mat;
e = struct('img', test_mat, ...
           'class', test_classes);
save('data/test_char_patches.mat', 'e');



