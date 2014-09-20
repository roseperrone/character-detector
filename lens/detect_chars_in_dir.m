SRC = '/Users/rose/iodine/lens/data/sep-11-train/';

all_files = dir(SRC);
% Removes the first three files, which are ., .., and .DS_Store
files = all_files(4:size(all_files, 1));
filenames = cell(1, size(files, 1));
for i = 1:size(files, 1)
   filenames(i) = {files(i).name};
end

f = fopen('data/predicted_chars.csv', 'a+');
count = 0;

for i = 1:size(filenames, 2)
    filename = filenames(i);
    for prediction = detect_chars(strcat(SRC, filename{1}))
        count = count + 1;
        fprintf(f, '%s,%d,%d,%d\n', prediction.filename, prediction.x, ...
            prediction.y, prediction.scale);
    end
end

disp(strcat(num2str(count), ' chars were detected'))
fclose(f);