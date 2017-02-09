% This file is similar to main.m file, but you do not have to go through
% the features calculation, which is very time consuming, anymore.

clc; clear;
data = load('temp/tweets_and_features.mat');
allTweets = data.allTweets;
features = data.features;

% Re-tweet removal
fprintf('\nRemoving re-tweets...');
[features, uniques, all] = unique(features, 'rows');
allTweets = allTweets(uniques,:);
fprintf('\nDone. %d tweets removed\n', length(all) - length(uniques));

%% =============== Part 2: Noise Removal ================
% Representation of Tweets via TF-IDF
fprintf('\nUsing TF-IDF to represent tweets...\n');
[y w] = tfidf2(features);
fprintf('Done\n');

fprintf('\nRemoving zero vectors in TF_IDF matrix...');
fprintf('\nThis will also remove tweets with nonvaluable contents...');
yNorm = sqrt(sum(y.^2,2));
zeroIndices = find(yNorm == 0);
y(zeroIndices,:) = []; % Remove from TF_IDF matrix
allTweets(zeroIndices) = [];
% save('data4kmeans.mat','allTweets', 'y');
fprintf('\nDone\n');

% Apply k-means or dbscan for noise removal
noisyTweetsIndices = dbScanNoiseRemoval(y);
% noisyTweetsIndices = kMeansNoiseRemoval(y);
allTweets(noisyTweetsIndices) = [];
y(noisyTweetsIndices,:) = [];

%% =============== Part 3: Clustering ================
% Apply k-means for clustering
numOfTweets = length(y(:,1));
concensus = zeros(numOfTweets, numOfTweets);
kMax = 12;
kMin = 2;
fprintf('\nClustering...\n');
distance = zeros(kMax - kMin, 1);
for k = kMin:kMax
    fprintf('With k is %d...\n', k);
    [idx, c, sumd] = kmeans(y, k, 'Distance', 'cosine');
    distance(k-kMin+1) = sum(sumd);
    for i = 1:numOfTweets
        for j = 1:numOfTweets
            if idx(i) == idx(j)
                concensus(i,j) = concensus(i,j) + 1;
            end
        end
    end
end
figure;
plot(kMin:kMax, distance);


% Some may need to modify the number of cluster below
k = 5
idx = kmeans(concensus, k, 'Distance', 'cosine');
fprintf('\nDone\n');

% Finding the most popular word in each cluster
for i = 1:k
    group = find(idx == i);
    tweetGroup = allTweets(group);
    fprintf('Most popular word from group %d is %s \n',...
        i, getPopularWordFromTweets(tweetGroup));
end

%% =============== Part 4: Visualization ================

% Export all tweets and its cluster information to nodes.csv. Data will be
% delimited by tab (\t) since there are colons and semicolons in tweets, so
% that those cannot work as delimiters.
fid = fopen('data/nodes.csv', 'w');
fprintf(fid, 'Id\tLabel\tModularity Class');
for i = 1:numOfTweets
fprintf(fid, '\n%d\t%s\t%f', i, allTweets{i}, idx(i));
end
fclose(fid);

% Export edges.csv, two tweets form an edge if they have been clustered
% together more than 8 times.
connection = [];
for i = 1:numOfTweets-1
    for j = i+1:numOfTweets
        if concensus(i,j) >= 8
            connection = [connection; i, j];
        end
    end
end

fid = fopen('data/edges.csv', 'w') ;
fprintf(fid, 'Source\tTarget');
for i= 1:length(connection)
    fprintf(fid, '\n%d\t%d', connection(i,1), connection(i,2));
end
fclose(fid);