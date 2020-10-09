% Deep learning on eyes open vs eyes closed
% data from Child Mind
% see restinstate_prepare.m for data segmentation
% Arnaud Delorme - September 2020

% get job information
jobid = getjobid
diary(sprintf('log_%s.txt', jobid.jobid));
mfilename
jobid = getjobid

dataType = 'raw' % do not add ;
% dataType = 'clean' % do not add ;

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

rng(1);
shuffledInd = shuffle([1:length(YOri)]);
trainInd = [1:round(length(YOri)*0.8)];
testInd  = [round(length(YOri)*0.8)+1:round(length(YOri)*0.9)];
holdInd  = [round(length(YOri)*0.9):length(YOri)];
XTrain = XOri(shuffledInd(trainInd)); YTrain = YOri(shuffledInd(trainInd));
XTest  = XOri(shuffledInd(testInd));  YTest  = YOri(shuffledInd(testInd));
XHold  = XOri(shuffledInd(holdInd));  YHold  = YOri(shuffledInd(holdInd));

if iscell(YTrain(1))
    catVals = { 'gender' 'age' 'handedness' 'eyeclosed' 'trial' }
    catInd = 4
    YTrain = categorical(cellfun(@(x)x(catInd), YTrain));
    YTest  = categorical(cellfun(@(x)x(catInd), YTest));
    YHold  = categorical(cellfun(@(x)x(catInd), YHold));
end


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
inputSize = size(XTrain{1},1);
numHiddenUnits = 100;
numClasses = 2;
inputLayerParameters = {'normalization', 'rescale-zero-one', 'normalizationdimension', 'channel' }'
layers = [ ...
    sequenceInputLayer(inputSize, inputLayerParameters{:})
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
    'MaxEpochs',3000, ... % number of steps
    'MiniBatchSize', 5000, ... % number of example used at each step, 128 default
    'InitialLearnRate', 0.0001, ...
    'SequenceLength','longest', ...
    'Shuffle','every-epoch', ... % or never, every-epoch
    'Verbose',1, ...
    'VerboseFrequency', 50, ...
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
