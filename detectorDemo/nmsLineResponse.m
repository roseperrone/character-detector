function responses = nmsLineResponse(vec, thresh, windowSize)

if ~exist('thresh')
  thresh = 0;
end

if ~exist('windowSize')
  windowSize = 5;
end

responses = zeros(1, length(vec));
vec = vec - thresh;
for i=1:length(vec)
  if vec(i) > 0 && vec(i) == max(vec(max(1,i-windowSize):min(length(vec), i+windowSize)))
    responses(i) = vec(i);
  end
end
