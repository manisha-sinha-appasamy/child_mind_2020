load('RestingState.mat');
for iEvent = 1:length(EEG.event)
    EEG.event(iEvent).latency = EEG.event(iEvent).sample;
end
evtSample = 0;
evtType  = 0;
refractoryPeriod = 0;
newevents = [];

while evtSample < EEG.pnts
    iEvent = find( [ EEG.event.latency ] < evtSample );
    
    if ~isempty(iEvent)
        if isequal( EEG.event(iEvent).type, '20  ')
            EEG.event(iEvent) = [];
            evtType = 1;
            refractoryPeriod = 3;
        elseif isequal( EEG.event(iEvent).type, '30  ')
            EEG.event(iEvent) = [];
            evtType = 2;
            refractoryPeriod = 3;
        else
            EEG.event(iEvent) = [];
            evtType = 0;
            refractoryPeriod = 3;
        end
    end
    
    if refractoryPeriod > 0
        refractoryPeriod = refractoryPeriod-1;
    else
        if isempty( find( [ EEG.event.latency ] < evtSample+EEG.srate )) % no event in the following second
            if evtType == 1
                newevents(end+1).type = 'EyesO';
                newevents(end).latency = evtSample;
            elseif evtType == 2
                newevents(end+1).type = 'EyesC';
                newevents(end).latency = evtSample;
            end
        end
    end
    evtSample = evtSample+EEG.srate;
    
end
EEG.event = newevents;

EEG2 = pop_epoch( EEG, {  'EyesO'  }, [0 1], 'epochinfo', 'yes');
EEG2.condition = 'eyeso';

EEG3 = pop_epoch( EEG, {  'EyesC'  }, [0 1], 'epochinfo', 'yes');
EEG3.condition = 'eyesc';

XTrain = {};
YTrain = [];
for iTrial = 1:EEG2.trials
    XTrain{end+1} = EEG2.data(:,:,iTrial);
    YTrain(end+1) = 0;
end
for iTrial = 1:EEG2.trials
    XTrain{end+1} = EEG3.data(:,:,iTrial);
    YTrain(end+1) = 1;
end
XTrain = XTrain';
YTrain = categorical(YTrain');

% LSTM
inputSize = 129;
numHiddenUnits = 100;
numClasses = 2;

layers = [ ...
    sequenceInputLayer(inputSize)
    bilstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer]

% Training
maxEpochs = 100;

options = trainingOptions('adam', ...
    'ExecutionEnvironment','auto', ...
    'GradientThreshold',1, ...
    'MaxEpochs',maxEpochs, ...
    'SequenceLength','longest', ...
    'Shuffle','never', ...
    'Verbose',0, ...
    'Plots','training-progress');
net = trainNetwork(XTrain,YTrain,layers,options);

