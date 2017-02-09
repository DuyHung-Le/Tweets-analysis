function word = getPopularWordFromTweets(tweets)
% GETPOPULARWORDFROMTWEETS get the most popular words in a number of input
% tweets
    % Create a matrix to store features of tweets collection. This matrix has
    % rows as samples (tweets) and columns as features. 1997 is the number of
    % words in vocab list, corresponding to 1997 features
    features = zeros(length(tweets), 1997);
    for i = 1: length(tweets)
        % You may want to comment the displaying of processed tweet in the
        % file processTweet, otherwise command window will be flooded with all
        % the tweets
        wordIndices = processTweet(tweets{i});
        features(i,:) = tweetFeatures(wordIndices);
    end
    wordFrequency = sum(features);
    popularWordIndex = find(wordFrequency == max(wordFrequency));
    vocabList = getVocabList();
    word = vocabList{popularWordIndex};
end
