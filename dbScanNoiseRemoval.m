function noisyTweets = dbScanNoiseRemoval(data)
% DBSCANNOISEREMOVAL Using dbscan with many values of epsilon to cluster a 
% list of tweets, in order to delete tweets that have the least connections
% to others. More details of the algorithm can be found at 
% http://meyer.math.ncsu.edu/Meyer/PS_Files/CaseStudyInTextMining.pdf
% Input: features vector of tweets (rows for tweets, columns for features),
% Output: The row indices of the input that can be considered noisy tweets.
% 
% Before running the script, I strongly recommend you to choose the value
% of MinPts first for dbscan, and then plotting kdist to see which values
% of epsilons to be considered.

minEps = 0.72;
maxEps = 0.75;
step = 0.005;
minPts = 4;

fprintf('Clustering using dbscan...\n');
TimeAsNoise = zeros(size(data,1), 1);
for i = minEps:step:maxEps
    fprintf('with minPts = %d and Eps = %f \n', minPts, i);
    class = dbscan2(data, minPts, i);
    notCore = find(class == 0);
    TimeAsNoise(notCore) = TimeAsNoise(notCore) + 1;
end
fprintf('\nDone\n');

fprintf('\nRemoving noisy tweets with dbscan...\n');
noisyTweets = find(TimeAsNoise > ((maxEps - minEps)/step + 1)/2);
end