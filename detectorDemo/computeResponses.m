function responses = computeResponses(img, filterStack, scales, usegpu)

if ~exist('usegpu')
  usegpu = 0;
end

if ~exist('scales')
  scales = [1.5,1.2:-0.1:0.1];
end

responses = cell(1,length(scales));
for i=1:length(scales)
  imgScaled = imresize(img, scales(i));
  if size(imgScaled, 3) == 3
    imgScaled = rgb2gray(imgScaled);
  end
  t = tic;
  responses{i} = fullImageForwardProp(imgScaled, filterStack, usegpu);
  responses{i} = responses{i}(:,:,1);
  fprintf('Computed responses at scale %.2f (%dx%d) in %.4f s\n', ...
	  scales(i), size(imgScaled,1), size(imgScaled,2), toc(t));
end
