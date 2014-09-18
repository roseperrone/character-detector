% Code written by Tao Wang (http://cs.stanford.edu/people/twangcat/)
% adjust the left and right boundaries of the recognized word
function[predword, dummy, matchScore, bounds] =  score2WordBounds(scores, lexicon)



    %[conf pred_y] = max(scores,[],1);
    
   
    case_insen_scores = [max(scores(1:26,:), scores(27:52,:)); max(scores(1:26,:), scores(27:52,:)); scores(53:62,:) ]; %make scores case-insensitive
    [dummy, good_idx, margin] = filterScores(scores,2, -100);

    s = length(good_idx);

    matchScoreArray = -9999*ones(1,length(lexicon));
    for i = 1:length(lexicon)
        lexiconword = regexprep(char(lexicon{i}),'[^a-zA-Z0-9]','');
        if length(lexiconword)>2
            [tempscore real_good_idx]= getMatchScore(case_insen_scores,lexiconword, good_idx);
            matchScoreArray(i) = tempscore;
        end
    end

    [matchScore, idx] = max(matchScoreArray);
    bestword = regexprep(char(lexicon{idx}),'[^a-zA-Z0-9]','');
    [tempscore real_good_idx]= getMatchScore(case_insen_scores,bestword, good_idx);
    bounds = [max(1, real_good_idx(1)-8), size(scores,2) - min(size(scores,2), real_good_idx(end)+8)]; %bounds(1) is the dist from 1st char to left margin, bounds(2) is the dist from last char to right margin
    
    predword=upper(regexprep(char(lexicon{idx}),'[^a-zA-Z0-9]',''));
    
    dummy = 0;
