% Code written by Tao Wang (http://cs.stanford.edu/people/twangcat/)

function [matchscore real_good_idx]= getMatchScore(origscores, origword, good_idx)

% given the char recognition score and a candidate lexicon word,
% computes the matchscore using dynamic programming
% origscores: the score matrix M
% origword: one single lexicon word
% good_idx: peak positions obtained after NMS on 'confidence margin'

scores = origscores(:,good_idx);
word=double(ascii2label(origword));
w = length(word);
if w<1
    matchscore = -10;
    real_good_idx = 0;
    return;
end
s = size(scores,2);
os = size(origscores,2);

% scoreMat(i,j) contains the maximum score you can get so far by matching
% the ith character with the jth score location

% if word is longer than number of sliding windows, something's wrong
if w>s
    matchscore = -10;
    real_good_idx = 0;
    return;
end
% dynamic programming window
scoreMat = zeros(w,s);
scoreIdx = zeros(w,s);
scoreMat(1,:)  = scores(word(1),:); % initialize first row

% Viterbi dynamic programming
for i = 2:w
    for j = i:s
        [maxPrev maxPrevIdx] = max(scoreMat(i-1, i-1:j-1));
        scoreMat(i,j) = scores(word(i), j) + maxPrev;

        scoreIdx(i,j) = maxPrevIdx;
    end
end

[matchscore lastidx]= max(scoreMat(end,w:end));

real_good_idx = zeros(1,w);
real_good_idx(end) = lastidx+w-1;
i = w;
% backtrace to find correspondence between peaks and chars.
while i>1
    real_good_idx(i-1) = scoreIdx(i, real_good_idx(i))+i-2;
    i = i-1;
end
real_good_idx = good_idx(real_good_idx);

gaps = [real_good_idx s] - [1 real_good_idx];


%% penalize geometric inconsistency
global c_std c_narrow;
% inconsistent character spacing
if length(gaps)>=4
    gaps = gaps(2:end-1);
    std_loss = c_std*std(gaps);
else
    std_loss = 0;
end
% very narrow characters
narrow_loss = 0;
if ~strcmp(origword,'I') && ~strcmp(origword,'l')
if (size(origscores,2))/w<8
    narrow_loss = (8-(size(origscores,2))/w)*c_narrow;
end
end

% penalize excessive extra space on both sides
matchscore = matchscore- std_loss-narrow_loss - ((min(real_good_idx) - 1)/os + (os-max(real_good_idx))/os);

