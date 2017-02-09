clear; close all; clc;

%% =============== Part 1: Loading and Clean Data ================
% Read tweet data and store it in a cell
fprintf('Getting tweet data...\n');
fileName = 'data/Tweets_2016London.csv';
allTweets = getData(fileName);

fprintf('\nGenerating vocabulary list from data...\n');
vocabFile = 'data/vocab.txt';
if not(exist(vocabFile, 'file'))
    genVocab(allTweets, vocabFile);
    % Remember to update the number of words in vocab list in 
    % getVocabList.m, tweetFeatures.m and getPopularWordFromTweets.m
    % after creating a new vocab list  
else
    fprintf('\nVocabulary file exists, no need to make a new one\n');
end

% Generating feature vectors for all the tweets
fprintf('\nGenerating feature vectors from tweets...\n');

% Create a matrix to store features of tweets collection. This matrix has
% rows as samples (tweets) and columns as features. 1997 is the number of 
% words in vocab list, corresponding to 1997 features
features = zeros(length(allTweets), 1997);  
for i = 1: length(allTweets)
    % You may want to comment the displaying of processed tweet in the
    % file processTweet, otherwise command window will be flooded with all
    % the tweets
    wordIndices = processTweet(allTweets{i});
    features(i,:) = tweetFeatures(wordIndices);
    if mod(i, 100) == 0
        temp = sprintf('%d...', i);
        fprintf(temp);
    end
end
fprintf('\nDone\n');
save('temp/tweets_and_features.mat', 'allTweets', 'features');

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

% Apply k-means or dbscan for noise removal, comment either of two below
% line and uncomment the other
noisyTweetsIndices = dbScanNoiseRemoval(y);
% noisyTweetsIndices = kMeansNoiseRemoval(y);
% noisyTweetsIndices = kMeansNoiseRemoval(y);
allTweets(noisyTweetsIndices) = [];
y(noisyTweetsIndices,:) = [];

%% =============== Part 3: Clustering ================
% Apply k-means for clustering
numOfTweets = length(y(:,1));
concensus = zeros(numOfTweets, numOfTweets);
kMax = 12;
kMin = 2;
fprintf('\nClustering with kmeans...\n');
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
plot(kMin:kMax, distance); xlabel('k'); ylabel('distance');


k = input('Select the value of k\n');
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
fprintf('\nThe program has finished!\n');