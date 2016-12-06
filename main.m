clear; close all; clc;

%% =============== Part 1: Loading and Clean Data ================
% Read tweet data and store it in a cell
fprintf('Getting tweet data...\n');
fileName = 'data/Tweets_2016London.csv';
allTweets = getData(fileName);


fprintf('\nGenerating vocabulary list from data...\n');
vocabFile = 'data/vocab.txt';
if not(exist(vocabFile, 'file'))
    genVocab(allTweets(), vocabFile);
    % Remember to update the number of word in vocab list in 
    % getVocabList.m and tweetFeatures.m after creating a new vocab list  
else
    fprintf('\nVocabulary file exists, no need to make a new one\n');
end

% Generating feature vectors for all the tweets
fprintf('\nGenerating feature vectors from tweets...\n');
features = zeros(2021, length(allTweets)); % 2021 is the number of words in vocab list 
for i = 1: length(allTweets)
    % You may want to comment the displaying of processed tweet in the
    % file processTweet, otherwise command window will be flooded with all
    % the tweets
    wordIndices = processTweet(allTweets{i});
    features(:,i) = tweetFeatures(wordIndices);
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
[Y w] = tfidf2(features);
fprintf('Done\n');



