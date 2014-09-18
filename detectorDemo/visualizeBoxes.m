function visualizeBoxes(img, response, thresh)

if ~exist('thresh')
  thresh = 1.5;
end

bboxes = response.bbox;
spaces = response.spaces;
chars  = response.chars;

imshow(img);
for i=1:size(bboxes, 1)
  if bboxes(i,5) > thresh && bboxes(i,3) > 0 && bboxes(i,4) > 0
   rectangle('Position', bboxes(i, 1:4), 'EdgeColor', 'g', 'LineWidth', 2);
    
   spaceLocations = sort(spaces(i).locations);
   for j=1:length(spaceLocations)
     rectangle('Position', [bboxes(i,1) + spaceLocations(j), bboxes(i,2), 2, bboxes(i,4)], 'EdgeColor', 'b', 'FaceColor', 'b');
   end
  end
end
