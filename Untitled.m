clc; clear;
data = load('data4kmeans.mat');
tweets = data.allTweets;
y = data.y;

% Apply k-means for noise removal
noisyTweetsIndices = kMeansNoiseRemoval(y);
tweets(noisyTweetsIndices) = [];
y(noisyTweetsIndices,:) = [];

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

idx = kmeans(concensus, 5, 'Distance', 'cosine');



