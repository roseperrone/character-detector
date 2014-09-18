function response = findBoxesFull(responses, scales)

if ~exist('scales')
  scales = [1.5,1.2:-0.1:0.1];
end

bboxes = [];
spaces = [];
chars  = [];
lineResponses = [];

for j=1:length(responses)
  [b, s, c, r] = findLinesFull(responses{j}, scales(j));
  
  bboxes = vertcat(bboxes, b);
  spaces = horzcat(spaces, s);
  chars  = horzcat(chars , c);
  lineResponses = horzcat(lineResponses, r);
end

[bboxes, indices] = nmsBBoxes(bboxes, 0.5);
spaces = spaces(indices);
chars = chars(indices);
lineResponses = lineResponses(indices);

response = struct('bbox', bboxes, 'spaces', spaces, 'chars', chars, 'responses', lineResponses);
