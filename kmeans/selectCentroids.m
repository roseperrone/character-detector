function newD = selectCentroids(D, varthresh)
% remove centroids whos variance is lower than varthresh
varD = [];
newD = [];

for i = 1:size(D,1)
    d = (D(i,:)-min(D(i,:)))/(max(D(i,:))-min(D(i,:)));
    varD = [varD; var(d)];
    if var(d)>varthresh
        newD = [newD; D(i,:)];
    end
end

