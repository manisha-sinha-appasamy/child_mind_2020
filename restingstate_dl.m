% Deep learning on eyes open vs eyes closed
% data from Child Mind
% see restinstate_prepare.m for data segmentation
% Arnaud Delorme - September 2020

% load the data
if ~exist('XOri', 'var')
    % Load prepared data
    % XTrain - cell array of elements 129 channels x 100 samples
    % YTrain - categorical array of 0 and 1s (same length as XTrain)
    restingstate_loaddata;
end

rng(1);
percentTrain = 0.8;
shuffledInd = shuffle([1:length(YOri)]);
trainInd = [1:round(length(YOri)*percentTrain)];
testInd  = [round(length(YOri)*0.8)+1:round(length(YOri)*0.9)];
holdInd  = [round(length(YOri)*0.9):length(YOri)];
XTrain = XOri(shuffledInd(trainInd)); YTrain = YOri(shuffledInd(trainInd));
XTest  = XOri(shuffledInd(testInd));  YTest  = YOri(shuffledInd(testInd));
XHold  = XOri(shuffledInd(holdInd));  YHold  = YOri(shuffledInd(holdInd));

diary(['log_' datestr(now, 'yyyy-mm-dd_HH:MM') '.txt'] );
fprintf('Traning length: %1.0f (n=%d)\n', percentTrain, length(trainInd));
try
    d = gpuDevice
catch
    try
        gcp
    catch
    end
end
% network architecture
inputSize = 129;
numHiddenUnits = 100;
numClasses = 2;
layers = [ ...
    sequenceInputLayer(inputSize, 'normalization', 'zscore', 'normalizationdimension', 'channel')
%    bilstmLayer(numHiddenUnits,'OutputMode','last')
    ... % lstmLayer(numHiddenUnits,'OutputMode','last')
    bilstmLayer(numHiddenUnits,'OutputMode','last')
%     fullyConnectedLayer(numHiddenUnits/2)
%     gruLayer(numHiddenUnits/2,'OutputMode','last')
%     fullyConnectedLayer(numHiddenUnits/4)
%     gruLayer(numHiddenUnits/4,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer]
    % analyzeNetwork(layers); % show network
    
% Training parameters
options = trainingOptions('adam', ...
    'ExecutionEnvironment','gpu', ...
    'MaxEpochs',100, ... % number of steps
    'MiniBatchSize', 128, ... % number of example used at each step, 128 default
    'SequenceLength','longest', ...
    'InitialLearnRate', 0.001, ...
    'Shuffle','every-epoch', ... % or never, every-epoch
    'Verbose',1, ...
    'VerboseFrequency', 50, ...
    'Plots','training-progress') % visual interface

% Train network
tic; net = trainNetwork(XTrain,YTrain,layers,options); toc
close;

% Accuracy on training data
YPred = classify(net,XTest, 'SequenceLength','longest');
acc = sum(YTest == YPred)./numel(YTest);
ci = bootci(1000, {@mean YTest==YPred}, 'type', 'per');
fprintf('Accuracy: %1.5f-%1.5f\n', ci(1), ci(2));


diary off;
