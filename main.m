clear; close all; clc;

%% =============== Part 1: Loading and Visualizing Data ================
% Read tweet data and store it in a cell
fprintf('Getting tweet data...\n');
fileName = 'Tweets_2016London.csv';
X = getData(fileName);

genVocab(X);
