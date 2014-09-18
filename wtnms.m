% perform non-max suppression on sliding window classifier scores
function [mask,I] = wtnms(s, rad)
  assert(size(s,1) == 1);
  if rad>0
  s_pad = [zeros(size(s,1),rad), s, zeros(size(s,1),rad)];
  winmax = max(im2col(s_pad, [1, 2*rad+1]));
  mask = bsxfun(@ge, s, winmax - eps*2);
  else
      mask = ones(size(s));
  end
  I = find(mask);
  end
