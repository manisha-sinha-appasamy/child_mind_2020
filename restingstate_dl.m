% Deep learning on eyes open vs eyes closed
% data from Child Mind
% see restinstate_prepare.m for data segmentation
% Arnaud Delorme - September 2020

dataType = 'raw' % do not add ;
dataType = 'clean' % do not add ;

% load the data
if ~exist('XOri', 'var')
    % Load prepared data
    % XTrain - cell array of elements 129 channels x 100 samples
    % YTrain - categorical array of 0 and 1s (same length as XTrain)
    if strcmpi(dataType, 'raw')
        restingstate_loaddata; % change also name below
    else
        restingstate_loaddata_clean; % change also name below
    end
end

% set individuals
uniquePersonVal = cellfun(@(x)x(2)+x(3), YOri);
kid = [0;cumsum(diff(uniquePersonVal) ~= 0)];
%tmp = [kid uniquePersonVal]; tmp(1:20,:)
uniqueKid = unique(kid);

% select training and testing set
YFinal = categorical(cellfun(@(x)x(1), YOri)); % gender=1 { 'gender' 'age' 'handedness' 'eyeclosed' 'trial' }
rng(1);
kidInds = randperm(length(uniqueKid));

numTrain= ceil(length(uniqueKid)*0.8);
kidTrain = uniqueKid(1:numTrain);
indTrain = ismember(kid, kidTrain);
XTrain = XOri(indTrain);
YTrain = YFinal(indTrain);

kidTest = uniqueKid(numTrain+1:end);
indTest = ismember(kid, kidTest);
XTest  = XOri(indTest);
YTest  = YFinal(indTest);

try
    d = gpuDevice
catch
    try
        gcp
    catch
    end
end
% network architecture
% 20 hidden bilstmLayer units -> 70%
% 20 hidden bilstmLayer units -> 70%

inputSize = size(XTrain{1},1);
numHiddenUnits = 12;
numClasses = 2;
inputLayerParameters = {'normalization', 'zerocenter', 'normalizationdimension', 'channel' }'
layers = [ ...
    sequenceInputLayer(inputSize, inputLayerParameters{:})
%    bilstmLayer(numHiddenUnits,'OutputMode','last')
    ... % lstmLayer(numHiddenUnits,'OutputMode','last')
    bilstmLayer(numHiddenUnits,'OutputMode','last')
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
miniBatchSize = 1024; % power of 2
valFrequency = floor(length(XOri)/miniBatchSize);
options = trainingOptions('adam', ...
    'ExecutionEnvironment','gpu', ...
    'MaxEpochs',180, ... % number of steps
    'MiniBatchSize', miniBatchSize, ... % number of example used at each step, 128 default
    'InitialLearnRate', 0.001, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, ...
    'LearnRateDropPeriod', 40, ... % or 30
    'ValidationData', {XTest YTest}, ...
    'ValidationFrequency', valFrequency, ...
    'SequenceLength','longest', ...
    'Shuffle','every-epoch', ... % or never, every-epoch
    'Plots','training-progress') % visual interface

% Train network
tic; net = trainNetwork(XTrain,YTrain,layers,options); toc

% Accuracy on training data
YPred = classify(net,XTest, 'SequenceLength','longest');
acc = sum(YTest == YPred)./numel(YTest);
fprintf('Average accuracy: %1.5f\n', acc);

% save network
filenameNet = sprintf('net_%s.mat', jobid.jobid);
save('-mat', filenameNet, 'net');

% more accuracy - sometimes requires memory so better save the net first
ci = bootci(1000, {@mean YTest==YPred}, 'type', 'per'); 
fprintf('Accuracy 95conf : %1.5f-%1.5f\n', ci(1), ci(2));
diary off;
