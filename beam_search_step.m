% Code written by Tao Wang (http://cs.stanford.edu/people/twangcat/)

function [newstates curr]= beam_search_step(states, curr, origscores, segs, spacescores, numbeams, lexicon, thresh, c_split)
global scoreTable wordsTable;
% performs one step of word level beam search. expands all child paths from current
% states, and keeps the best 'numbeams' paths according to cumulative match
% scores, and return them in newstates.

% path format: one num for each seg, 
% 0 - unassigned
% 1 - the seg contains a complete word
% 2 - the seg contains the starting of a word but should join with the next seg
% 3 - the seg contains the ending of a word but should join with the prev seg
% 4 - the seg sould join with prev and next segs
% 5 - the seg contains no text
% segs is a sx2 array, each row is the starting and ending pixel of a seg.

%candidate new paths
if isempty(states) % this is first call to the function, states are empty. Initialize the root and its 2 candidate children
    can_path = zeros(3, size(segs,1));
    %can_scores = -1.5*ones(size(can_path));
    can_scores = thresh*ones(size(can_path));
    currseg = 1;
else
    can_path = zeros(5*length(states), length(states{1}.path));
    %can_scores = -1.5*ones(size(can_path));
    can_scores = thresh*ones(size(can_path));
    currseg = curr;
end

split_cost = 0; % penalty for split, depends on the spacescores. higher spacescores means lower penalty.
if ~isempty(spacescores) && currseg<= length(spacescores)
    split_cost = c_split^(-spacescores(currseg));
end

% expand all paths by 1 seg to get new paths
if currseg == 1 % looking at the 1st seg
    can_path(1,1) = 1;
    can_path(2,1) = 2;
    can_path(3,1) = 5;
    
    if scoreTable(1,2)>-90 % score of this candidate path has been computed and stored. No need to compute again.
        word = wordsTable{1,2};
        matchscore = scoreTable(1,2);
    else
        subscores = origscores(:,segs(1,1):segs(1,2));
        [word, ~, matchscore, bounds] =  score2Word(subscores, lexicon);
        matchscore = matchscore - split_cost;   
        wordsTable{1,2} = word;
        scoreTable(1,2) = matchscore;
    end
    % update word sequence and their respective scores of
    % candidate path
    can_scores(1, 1) = matchscore;
    can_words{1}{1} = word;
    can_words{2}{1} = '';
    can_words{3}{1} = '';
else % looking at subsequent segs
    can_path_cnt = 1;
    for i = 1:length(states)
        switch states{i}.path(currseg-1)
            %prev seg is a completed word
            case {1, 3}
                % 1. curr seg is a complete word
                can_path(can_path_cnt, :) = states{i}.path;
                can_path(can_path_cnt, currseg) = 1;
                if scoreTable(currseg,currseg+1)>-90
                    word = wordsTable{currseg,currseg+1};
                    matchscore = scoreTable(currseg,currseg+1);
                else
                    subscores = origscores(:,segs(currseg,1):segs(currseg,2));
                    [word, ~, matchscore, bounds] = score2Word(subscores, lexicon);
                    matchscore = matchscore - split_cost;
                    wordsTable{currseg,currseg+1} = word;
                    scoreTable(currseg,currseg+1) = matchscore;
                end
                % update word sequence and their respective scores of
                % candidate path
                can_scores(can_path_cnt, :) = states{i}.scores;
                can_scores(can_path_cnt, currseg) = matchscore;
                can_words{can_path_cnt} = states{i}.words;
                can_words{can_path_cnt}{end+1} = word;
                can_path_cnt = can_path_cnt+1;
                
                % 2. curr seg joins with its next seg.
                if currseg<size(segs,1)
                    can_path(can_path_cnt, :) = states{i}.path;
                    can_path(can_path_cnt, currseg) = 2;
                    can_scores(can_path_cnt, :) = states{i}.scores;
                    can_words{can_path_cnt} = states{i}.words;
                    % no need to update word sequence or scores
                    can_path_cnt = can_path_cnt+1;
                end
                
                % 3. curr seg contains no text
                can_path(can_path_cnt, :) = states{i}.path;
                can_path(can_path_cnt, currseg) = 5;
                can_scores(can_path_cnt, :) = states{i}.scores;
                can_words{can_path_cnt} = states{i}.words;
                % no need to update word sequence or scores
                can_path_cnt = can_path_cnt+1;
                
            %prev seg joins with current one.    
            case{2,4}
                % 1. curr seg is the end of a word
                can_path(can_path_cnt, :) = states{i}.path;
                can_path(can_path_cnt, currseg) = 3;
                segbounds = get_seg_bounds(can_path(can_path_cnt,:), segs);
                if scoreTable(segbounds(1),segbounds(2)+1)>-90
                    word = wordsTable{segbounds(1),segbounds(2)+1};
                    matchscore = scoreTable(segbounds(1),segbounds(2)+1);
                else 
                    subscores = origscores(:, segs(segbounds(1),1):segs(segbounds(2),2));
                    [word, ~, matchscore, bounds] =  score2Word(subscores, lexicon);
                    matchscore = matchscore - split_cost;
                    wordsTable{segbounds(1),segbounds(2)+1} = word;
                    scoreTable(segbounds(1),segbounds(2)+1) = matchscore;
                end
                % update word sequence and their respective scores of
                % candidate path
                can_scores(can_path_cnt, :) = states{i}.scores;
                can_scores(can_path_cnt, currseg) = matchscore;
                can_words{can_path_cnt} = states{i}.words;
                can_words{can_path_cnt}{end+1} = word;
                can_path_cnt = can_path_cnt+1;
                
                
                % 2. curr seg joins with its next seg.
                if currseg<size(segs,1)
                    can_path(can_path_cnt, :) = states{i}.path;
                    can_path(can_path_cnt, currseg) = 4;
                    can_scores(can_path_cnt, :) = states{i}.scores;
                    can_words{can_path_cnt} = states{i}.words;
                    % no need to update word sequence or scores
                    can_path_cnt = can_path_cnt+1;
                end
                
                
                
             
  
            %prev seg contains no text
            case 5
                % 1. curr seg is a complete word
                can_path(can_path_cnt, :) = states{i}.path;
                can_path(can_path_cnt, currseg) = 1;
                %evaluate matchscore of the new seg
                if scoreTable(currseg,currseg+1)>-90
                    word = wordsTable{currseg,currseg+1};
                    matchscore = scoreTable(currseg,currseg+1);
                else
                    subscores = origscores(:,segs(currseg,1):segs(currseg,2));
                    [word, bestdist, matchscore, bounds] =  score2Word(subscores, lexicon);
                    matchscore = matchscore - split_cost;
                    wordsTable{currseg,currseg+1} = word;
                    scoreTable(currseg,currseg+1) = matchscore;
%                     figure(1);
%                     imshow(subimg);
%                     pause;
                end
                % update word sequence and their respective scores of
                % candidate path
                can_scores(can_path_cnt, :) = states{i}.scores;
                can_scores(can_path_cnt, currseg) = matchscore;
                can_words{can_path_cnt} = states{i}.words;
                can_words{can_path_cnt}{end+1} = word;
                can_path_cnt = can_path_cnt+1;

                % 2. curr seg joins with its next seg.
                if currseg<size(segs,1)
                    can_path(can_path_cnt, :) = states{i}.path;
                    can_path(can_path_cnt, currseg) = 2;
                    can_scores(can_path_cnt, :) = states{i}.scores;
                    can_words{can_path_cnt} = states{i}.words;
                    % no need to update word sequence or scores
                    can_path_cnt = can_path_cnt+1;
                end
                
                % 3. curr seg contains no text
                can_path(can_path_cnt, :) = states{i}.path;
                can_path(can_path_cnt, currseg) = 5;
                can_scores(can_path_cnt, :) = states{i}.scores;
                can_words{can_path_cnt} = states{i}.words;
                % no need to update word sequence or scores
                can_path_cnt = can_path_cnt+1;
        end
    end
end

sum_can_path = sum(can_path,2);
valid_idx = find(abs(sum_can_path)>1e-6); % remove paths that are essentially all 0's, which are empty paths.
can_scores = can_scores(valid_idx, :);
can_path = can_path(valid_idx, :);
sum_can_scores = sum(can_scores,2);
[~, scores_idx] = sort(sum_can_scores, 'descend');
if length(valid_idx)>numbeams
    keep_idx = scores_idx(1:numbeams);
else
    keep_idx = scores_idx(valid_idx);
end

for i = 1:length(keep_idx)
    k = keep_idx(i);
    newstates{i}.path = can_path(k,:);
    newstates{i}.scores = can_scores(k,:);
    newstates{i}.words = can_words{k};
    newstates{i};
end
curr = currseg+1;
end

function segbounds = get_seg_bounds(path, segs)
% finds the correct bounds of the subimg given that the current segment
% should join with previous ones. 
segbounds = zeros(1,2);
idx = max(find(path==3));
segbounds(2) = idx;
while true
    idx = idx-1;
    if path(idx)~=4
        assert(path(idx)==2); % this chunck better have a start
        segbounds(1) = idx;
        break;
    end
end


end

