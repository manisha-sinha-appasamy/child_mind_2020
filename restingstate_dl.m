% Deep learning on eyes open vs eyes closed
% data from Child Mind
% see restinstate_prepare.m for data segmentation
% Arnaud Delorme - September 2020

% load the data
if exist('TrainData.mat', 'file')
    % Load prepared data
    % XTrain - cell array of elements 129 channels x 100 samples
    % YTrain - categorical array of 0 and 1s (same length as XTrain)
    load('-mat', 'TrainData.mat');
else
    error('Missing training data');
end

% network architecture
inputSize = 129;
numHiddenUnits = 2000;
numClasses = 2;
layers = [ ...
    sequenceInputLayer(inputSize, 'normalization', 'zerocenter')
    ... % bilstmLayer(numHiddenUnits,'OutputMode','last')
    ... % lstmLayer(numHiddenUnits,'OutputMode','last')
    ... % gruLayer(numHiddenUnits,'OutputMode','last')
    ... % fullyConnectedLayer(numHiddenUnits)
    gruLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer]
    % analyzeNetwork(layers); % show network

% Training parameters
maxEpochs = 2000;
options = trainingOptions('adam', ...
    'ExecutionEnvironment','gpu', ...
    'GradientThreshold',1, ...
    'MaxEpochs',2000, ... % number of steps
    'MiniBatchSize', 160, ... % number of example used at each step
    'SequenceLength','longest', ...
    'Shuffle','every-epoch', ... % or never
    'Verbose',1, ...
    'VerboseFrequency', 20);
    %    'Plots','training-progress'); % visual interface

% Train network
tic; net = trainNetwork(XTrain,YTrain,layers,options); toc

% Accuracy on training data
YPred = classify(net,XTrain, 'SequenceLength','longest');
acc = sum(YTrain == YPred)./numel(YTrain);
fprintf('Accuracy; %1.2f\n', acc);
