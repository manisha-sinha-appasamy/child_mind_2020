if exist('TrainData.mat', 'file')
    % Load prepared data
    % XTrain - cell array of elements 129 channels x 100 samples
    % YTrain - categorical array of 0 and 1s (same length as XTrain)
    load('-mat', 'TrainData.mat');
else
        end
    end
    
    XTrain = [XTrain{:} ]';
    YTrain = categorical( [YTrain{:} ]');
    inds = find(cellfun(@(x)size(x,2), XTrain) >100);
    XTrain(inds) = [];
    YTrain(inds) = [];
    save('-mat', 'TrainData.mat', 'XTrain', 'YTrain');
end
% LSTM
inputSize = 129;
numHiddenUnits = 2000;
numClasses = 2;

%    bilstmLayer(numHiddenUnits,'OutputMode','last')
%    lstmLayer(numHiddenUnits,'OutputMode','last')
layers = [ ...
    sequenceInputLayer(inputSize, 'normalization', 'zerocenter')
    gruLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numHiddenUnits)
    gruLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer]

% Training
maxEpochs = 2000;

options = trainingOptions('adam', ...
    'ExecutionEnvironment','gpu', ...
    'GradientThreshold',1, ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize', 160, ...
    'SequenceLength','longest', ...
    'Shuffle','every-epoch', ... % or never
    'Verbose',1, ...
    'VerboseFrequency', 20);
%    'Plots','training-progress');
tic
net = trainNetwork(XTrain,YTrain,layers,options);
YPred = classify(net,XTrain, 'SequenceLength','longest');
acc = sum(YTrain == YPred)./numel(YTrain)
toc
tic
net = trainNetwork(XTrain,YTrain,layers,options);
YPred = classify(net,XTrain, 'SequenceLength','longest');
acc = sum(YTrain == YPred)./numel(YTrain)
toc