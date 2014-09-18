function [finalBoxes, indices] = nmsBBoxes(bboxes, ratio)

if ~exist('ratio')
  ratio = 0.5;
end

if size(bboxes,1) == 0
  finalBoxes = [];
  indices = [];
  return;
end

%scores = bboxes(:,6);
scores = bboxes(:,5);
[scores, perm] = sort(scores, 'descend');

%scales = bboxes(perm 5);
otherVal = bboxes(perm, 6:end);
bboxes = bboxes(perm, 1:4);

areas = bboxes(:,3).*bboxes(:,4);
suppressed = zeros(size(bboxes, 1), 1);
finalBoxes = [];
indices = [];

aspectRatios = bboxes(:,3) ./ bboxes(:,4);
%suppressed(aspectRatios < 1) = 1;
%suppressed(aspectRatios > 10) = 1;
for i=1:size(bboxes,1)
  if suppressed(i)
    continue;
  end
  
  finalBoxes = [finalBoxes; bboxes(i,:), scores(i), otherVal(i,:)];

  int = rectint(bboxes(i,:), bboxes(i+1:end,:))';

  if length(int) == 0
    break;
  end

%  ratios = int ./ (areas(i) + areas(i+1:end,:) - int);
  ratios = int ./ min(areas(i), areas(i+1:end,:));
  indices = find(ratios > ratio) + i;
  suppressed(indices) = 1;
end

indices = perm(suppressed == 0);
