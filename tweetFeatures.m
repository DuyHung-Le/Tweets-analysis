function x = tweetFeatures(wordIndices)
%tweetFeatures takes in a wordIndices vector and produces a feature vector
%from the word indices
%   x = tweetFeatures(wordIndices) takes in a wordIndices vector and
%   produces a feature vector from the word indices.

% Total number of words in the dictionary
n = 2021;

% You need to return the following variables correctly.
x = zeros(n, 1);

% ====================== YOUR CODE HERE ======================
% Instructions: Fill in this function to return a feature vector for the
%               given email (wordIndices). To help make it easier to
%               process the emails, we have have already pre-processed each
%               email and converted each word in the email into an index in
%               a fixed dictionary (of 2135 words). The variable
%               wordIndices contains the list of indices of the words
%               which occur in one email.
%
%               Concretely, if an email has the text:
%
%                  The quick brown fox jumped over the lazy dog.
%
%               Then, the wordIndices vector for this text might look
%               like:
%
%                   60  100   33   44   10     53  60  58   5
%
%               where, we have mapped each word onto a number, for example:
%
%                   the   -- 60
%                   quick -- 100
%                   ...
%
%              (note: the above numbers are just an example and are not the
%               actual mappings).
%
%              This task is to take one such wordIndices vector and construct
%              a feature vector that indicates how many times a particular
%              word occurs in the email. That is, x(i) = 1 when word i
%              is present one time in the email. Concretely, if the word 'the'
%              (say, index 60) appears in the email, then x(60) = 1. The feature
%              vector should look like:
%
%              x = [ 0 0 0 0 1 0 0 0 ... 0 0 0 0 2 ... 0 0 0 3 0 ..];
%
%
for i=1:size(wordIndices)
    x(wordIndices(i)) = x(wordIndices(i)) + 1;
end

% =========================================================================


end
