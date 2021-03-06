function genVocab(allTweets, vocabFile)
% GENVOCAB Generate a vocabolary list from tweets
%   allTweets: cell of tweets, each tweet is one element
%   No output, the vocab list will be written in a local file, and later
%   be called by getVocabList().
    disp('Number of tweets have been processed: ');
    FREQ_LIMIT = 1;
    vocab = cell(0);
    tokens = containers.Map;

    for i=1:length(allTweets)
        if mod(i, 100) == 0
            temp = sprintf('%d...', i);
            fprintf(temp);
        end
        tweet = allTweets{i};

        % remove case-sensitive
        tweet = lower(tweet);

        % remove html
        tweet = regexprep(tweet, '<[^<>]+>', '');

        % remove number
        tweet = regexprep(tweet, '[0-9]+', '');

        % remove url
        tweet = regexprep(tweet, ...
            '(http|https)://[^\s]*', '');

        % remove Email Addresses
        % Look for strings with @ in the middle
        tweet = regexprep(tweet, '[^\s]+@[^\s]+', '');

        % remove $ sign
        tweet = regexprep(tweet, '[$]+', '');

        % ========================== Tokenize tweet ===========================

        while ~isempty(tweet)

            % Tokenize and also get rid of any punctuation
            [str, tweet] = ...
                strtok(tweet, ...
                [' @$/#.-:&*+=[]?!(){},''">_<;%' char(10) char(13)]);

            % Remove any non alphanumeric characters
            str = regexprep(str, '[^a-zA-Z0-9]', '');
            % Stem the word
            % (the porterStemmer sometimes has issues, so we use a try catch block)
            try str = porterStemmer(strtrim(str));
            catch str = ''; continue;
            end;

            % Skip the word if it is too short
            if length(str) < 2
                continue;
            end

            ks = keys(tokens);
            if (isempty(ks))
                tokens(str) = 1;
            else
                if nnz(strcmp(ks,str)) > 0
                    tokens(str) = tokens(str) + 1;
                else
                    tokens(str) = 1;
                end
            end
        end

    end

    % Put only word with frequency greater than FREQ_LIMIT to the vocab
    ks = keys(tokens);
    frequencies = values(tokens);
    for i=1:length(frequencies)
        if frequencies{i} > FREQ_LIMIT
            vocab = [vocab ; ks{i}];
        end
    end
    
    % ========================== Stop-word removal ========================
    % Remove stop word from the vocab list. To do this, we specified a list
    % that we considered stop words, including Determiners (like the, a, an),
    % Coordinating conjunctions (for, an, nor, ...) and Prepositions (in,
    % under,...). Be careful that those words in vocab list are stemmed
    % words, for example another would be anoth. Therefore, to be sure that
    % we are removing the right form of words, first time generating vocab
    % list we did not perform this step. Then for the second time, we called
    % processTweet with all the stop words to get the right form in vocab
    % list and store them to a file.
    % The following code will take all the stemmed stop-words and remove
    % them from the vocab list
    fid = fopen('data/stemmed_stop_words.txt', 'rt');
    content = textscan(fid,'%s');
    stopWords = content{1};
    fclose(fid);
    vocab = setdiff(vocab, stopWords); % Remove stopwords from vocab

    % Finish removing stop word, now sort our vocab list
    vocab = sort(vocab);


    fileID = fopen(vocabFile,'w');
    for i=1:length(vocab)
        if i<length(vocab)
            fprintf(fileID,'%d\t%s\n',i,vocab{i});
        else
            fprintf(fileID,'%d\t%s',i,vocab{i});
        end
    end

    fprintf('\nVocabulary successfully created!\n');
end
