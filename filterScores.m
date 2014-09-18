% Code written by Tao Wang (http://cs.stanford.edu/people/twangcat/)
% 
function [word, I_max, margin]= filterScores(s, NMS_RADIUS, marginThresh)
  CHAR_LIST = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  if (nargin < 2)
    NMS_RADIUS=2;
  end
  [conf pred_y] = max(s,[],1);
  % sort each column of scores
  validList='';
  [s_sorted,I_sorted] = sort(s);
  
  % compute difference between best score and second best.
  %margin = smooth(s_sorted(end,:) - s_sorted(end-1,:),3);
  margin = s_sorted(end,:) - s_sorted(end-1,:);
  margin = margin(:)';
  % do NMS on the margin ("confidence")
  [mask, I_max] = wtnms(margin, NMS_RADIUS);
  
  I_max = I_max(ismember(I_max, find(margin>marginThresh)));
  word = CHAR_LIST(pred_y(I_max));
