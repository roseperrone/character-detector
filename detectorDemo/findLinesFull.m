function [bboxes, spaces, chars, fullResponse] = findLinesFull(responseMap, scale, thresh, nSpaces)

if ~exist('scale')
  scale = 1;
end

if ~exist('thresh')
  thresh = 0.8;
end

if ~exist('nSpaces')
  nSpaces = 5;
end

bboxes = [];
spaces = struct('locations', {}, 'scores', {});
chars  = struct('locations', {}, 'scores', {});
fullResponse = struct('response', {}, 'scale', {});
for i=1:size(responseMap, 1)
  nms = nmsLineResponse(responseMap(i,:,1), thresh, 5);

  peaks = find(nms > 0);
  separations = diff(peaks);

  if length(peaks) == 3 && ((max(separations) / min(separations)) >= 3)
    continue;
  end 
  
  if length(peaks) >= 3 
    medianSep = median(separations);
    
    start = 1;

    for j=1:length(separations)
      if separations(j) > 5*medianSep
	if j - start >= 2
	  rect = [round(peaks(start)/scale), round(i/scale), ...
			     round((peaks(j)-peaks(start)+32)/scale), round(32/scale),...
			     mean(nms(peaks))];
	  bboxes(end+1, :) = rect;
	  
	  aspectRatio = rect(3) / rect(4);
	  if aspectRatio > 20
	    nSpaces = nSpaces * 4;
	  elseif aspectRatio > 10
	    nSpaces = nSpaces * 2;
	  end
	  
	  charScores = nms(peaks(start:j));
	  locations = round((peaks(start:j) - peaks(start)) / scale) + 1;
	
	  chars(end+1) = struct('locations', locations, 'scores', charScores);
	  fullResponse(end+1) = struct('response', responseMap(i, peaks(start):min(size(responseMap, 2), peaks(j)+31), 1), ...
				       'scale', scale);
  	  spaces(end+1) = getSpaces(responseMap, i, peaks(start), peaks(j), nSpaces, scale);
	end
	start = j + 1;
      end
    end
    
    j = j + 1;
    if j - start >= 2
      rect = [round(peaks(start)/scale), round(i/scale), ...
	      round((peaks(j)-peaks(start)+31)/scale), round(32/scale), ...
	      mean(nms(peaks))];
      
      bboxes(end+1, :) = rect;
      
      charScores = nms(peaks(start:j));
      locations = round((peaks(start:j) - peaks(start)) / scale) + 1;
      
      chars(end+1) = struct('locations', locations, 'scores', charScores);
      fullResponse(end+1) = struct('response', responseMap(i, min(size(responseMap, 2), peaks(start):peaks(j)+31), 1), ...
				   'scale', scale);
      spaces(end+1) = getSpaces(responseMap, i, peaks(start), peaks(j), nSpaces, scale);
    end
  end
end

function spaceData = getSpaces(responseMap, row, colStart, colEnd, nSpaces, scale)

rNms = nmsLineResponse(-responseMap(row,colStart:colEnd), 0.25, 10);

[~, indices] = sort(rNms, 'descend');
num = min(nSpaces, length(find(rNms > 0)));

scores = rNms(indices(1:num));

spaceData= struct('locations', min(round(colEnd/scale), ...
				   round((indices(1:num)+16)/scale)), ...
		  'scores', scores);
