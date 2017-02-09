function noisyTweets = kMeansNoiseRemoval(data)
% KMEANSNOISREMOVAL Using kmeans with many values of k to cluster a list of
% tweets, in order to delete tweets that have the least connections to
% others. More details of the algorithm can be found at 
% http://meyer.math.ncsu.edu/Meyer/PS_Files/CaseStudyInTextMining.pdf
% Input: features vector of tweets (rows for tweets, columns for features),
% Output: The row indices of the input that can be considered noisy tweets.

    numOfTweets = size(data,1);
    concensus = zeros(numOfTweets, numOfTweets);
    kMax = 11;
    kMin = 2;

    fprintf('Clustering using k-means...\n');
    for k = kMin:kMax
        fprintf('With k is %d...\n', k);
        idx = kmeans(data, k, 'Distance', 'cosine');
        for i = 1:numOfTweets
            for j = 1:numOfTweets
                if idx(i) == idx(j)
                    concensus(i,j) = concensus(i,j) + 1;
                end
            end
        end
    end
    fprintf('\nDone\n');

    fprintf('\nRemoving noisy tweets with kmeans...\n');
    for i = 1:numOfTweets
        for j = 1:numOfTweets
            if concensus(i,j) <= (kMax - kMin + 1)/10
                concensus(i,j) = 0;
            end
        end
    end

    rowSum = sum(concensus, 2);
    avg = mean(rowSum);
    noisyTweets = find(rowSum < avg);
end

%     numOfTweets = length(data(:,1));
%     concensus = zeros(numOfTweets, numOfTweets);
%     kMax = 12;
%     kMin = 2;
%     fprintf('\nClustering...\n');
%     distance = zeros(kMax - kMin, 1);
%     for k = kMin:kMax
%         fprintf('With k is %d...\n', k);
%         [idx, c, sumd] = kmeans(data, k, 'Distance', 'cosine');
%         distance(k-kMin+1) = sum(sumd);
%         for i = 1:numOfTweets
%             for j = 1:numOfTweets
%                 if idx(i) == idx(j)
%                     concensus(i,j) = concensus(i,j) + 1;
%                 end
%             end
%         end
%     end
%     figure;
%     plot(kMin:kMax, distance);

