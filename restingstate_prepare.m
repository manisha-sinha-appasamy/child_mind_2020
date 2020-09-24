% Prepare data
fileTrain = 'TrainData.mat';
if exist(fileTrain, 'file')
    s = input('Are you sure you want to delete the training data (CRTL-C to stop; enter to continue)', 's');
    delete(fileTrain);
end

% Add EEGLAB path
addpath('/home/arno/eeglab');
if isempty(which('eeg_checkset.m'))
    eeglab; close;
end

% Path to data
folderin = '../child-mind-uncompressed';
folders = dir(folderin);

XTrain = cell(1,length(folders));
YTrain = cell(1,length(folders));
issueFlag = cell(1, length(folders));
count = 1;
%parfor iFold = 1:length(folders)
for iFold = 1:6 %length(folders)
    
    fileName = fullfile(folders(iFold).folder, folders(iFold).name, 'EEG/raw/mat_format/RestingState.mat');
    if exist(fileName, 'file')
        try
            EEG = load(fileName);
            EEG = EEG.EEG;
            for iEvent2 = 1:length(EEG.event)
                EEG.event(iEvent2).latency = EEG.event(iEvent2).sample;
            end
            evtSample = 0;
            evtType  = 0;
            refractoryPeriod = 0;
            newevents = [];
            
            EEG = eeg_checkset(EEG);
            EEG = pop_resample(EEG, 100);
            
            iEvent = 0;
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
            
            for iTrial = 1:EEG2.trials
                XTrain{iFold}{end+1} = EEG2.data(:,:,iTrial);
                YTrain{iFold}(end+1) = 0;
            end
            for iTrial = 1:EEG2.trials % same number of trials
                XTrain{iFold}{end+1} = EEG3.data(:,:,iTrial);
                YTrain{iFold}(end+1) = 1;
            end
        catch
            issueFlag{iFold} = lasterr;
        end
    end
end

indIssue = find(~cellfun(@isempty, issueFlag));
fprintf('Issues at indices (empty means no issues): %s\n', int2str(indIssue));
if ~isempty(indIssue), issueFlag(indIssue)', end
XTrainOld = XTrain; % for debugging

% Concatenate
XTrain = [ XTrain{:} ]';
YTrain = categorical([ YTrain{:} ]');

% remove non-compliant data
inds = find(cellfun(@(x)size(x,2), XTrain) >100);
XTrain(inds) = [];
YTrain(inds) = [];

disp('Saving data...');
save('-mat', fileTrain, 'XTrain', 'YTrain');