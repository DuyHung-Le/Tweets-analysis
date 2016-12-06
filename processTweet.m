function wordIndices = processTweet(tweet)
%ProcessTweet preprocesses a the body of an tweet and
%returns a list of wordIndices
%   wordIndices = ProcessTweet(tweet) preprocesses
%   the body of an tweet and returns a list of indices of the
%   words contained in the tweet.
%

% Load Vocabulary
vocabList = getVocabList();

% Init return value
wordIndices = [];

% ========================== Preprocess Tweet ===========================

% Find the Headers ( \n\n and remove )
% Uncomment the following lines if you are working with raw emails with the
% full headers

% hdrstart = strfind(tweet, ([char(10) char(10)]));
% tweet = tweet(hdrstart(1):end);

% Lower case
tweet = lower(tweet);

% Strip all HTML
% Looks for any expression that starts with < and ends with > and replace
% and does not have any < or > in the tag it with a space
tweet = regexprep(tweet, '<[^<>]+>', ' ');

% Handle Numbers
% Look for one or more characters between 0-9
tweet = regexprep(tweet, '[0-9]+', 'number');

% Handle URLS
% Look for strings starting with http:// or https://
tweet = regexprep(tweet, ...
                           '(http|https)://[^\s]*', 'httpaddr');

% Handle tweet Addresses
% Look for strings with @ in the middle
tweet = regexprep(tweet, '[^\s]+@[^\s]+', 'emailaddr');

% Handle $ sign
tweet = regexprep(tweet, '[$]+', 'dollar');


% ========================== Tokenize tweet ===========================

% Output the tweet to screen as well
fprintf('\n==== Processed tweet ====\n\n');

% Process file
l = 0;

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
    if length(str) < 1
       continue;
    end

    % Look up the word in the dictionary and add to wordIndices if
    % found
    % ====================== YOUR CODE HERE ======================
    % Instructions: Fill in this function to add the index of str to
    %               wordIndices if it is in the vocabulary. At this point
    %               of the code, you have a stemmed word from the tweet in
    %               the variable str. You should look up str in the
    %               vocabulary list (vocabList). If a match exists, you
    %               should add the index of the word to the wordIndices
    %               vector. Concretely, if str = 'action', then you should
    %               look up the vocabulary list to find where in vocabList
    %               'action' appears. For example, if vocabList{18} =
    %               'action', then, you should add 18 to the wordIndices
    %               vector (e.g., wordIndices = [wordIndices ; 18]; ).
    %
    % Note: vocabList{idx} returns a the word with index idx in the
    %       vocabulary list.
    %
    % Note: You can use strcmp(str1, str2) to compare two strings (str1 and
    %       str2). It will return 1 only if the two strings are equivalent.
    %
    for i = 1:length(vocabList)
        if strcmp(vocabList{i},str) == 1
            wordIndices = [wordIndices ; i];
            break;
        end
    end


    % =============================================================


    % Print to screen, ensuring that the output lines are not too long
    if (l + length(str) + 1) > 78
        fprintf('\n');
        l = 0;
    end
    fprintf('%s ', str);
    l = l + length(str) + 1;

end

% Print footer
fprintf('\n\n=========================\n');

end
