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
% rows as samples (tweets) and columns as features. 2003 is the number of 
% words in vocab list, corresponding to 2003 features
features = zeros(length(allTweets), 2003);  
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

% Re-tweet removal

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
save('data4kmeans.mat','allTweets', 'y');
fprintf('\nDone\n');

% Apply k-means for noise removal
noisyTweetsIndices = kMeansNoiseRemoval(y);
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
idx = kmeans(concensus, 5, 'Distance', 'cosine');
fprintf('Done\n');

% Sample code for finding the most popular word in each cluster
group1 = find(idx == 1);
tweetGroup1 = allTweets(group1);
getPopularWordFromTweets(tweetGroup1)





