clear
addpath('/home/arno/eeglab');
eeglab; close;

% get XOri, XTest and XHold
folderout = '../child-mind-restingstate';
fileNames = dir(fullfile(folderout, '*.set'));

XOri = cell(1,length(fileNames));
YOri = cell(1,length(fileNames));
for iFile = 1:length(fileNames)
    fprintf('Dataset %d\n', iFile);
    EEG = pop_loadset(fullfile(fileNames(iFile).folder, fileNames(iFile).name));
    if mod(EEG.trials,2) == 0
        for iTrial = 1:EEG.trials
            XOri{iFile}{end+1} = EEG.data(:,:,iTrial);
        end
        YOri{iFile} = [ zeros(1, EEG.trials/2) ones(1, EEG.trials/2)];
    else
        error('Number of trials must be even');
    end
end

XOriOld = XOri; % for debugging

% Concatenate
XOri = [ XOri{:} ]';
YOri = categorical([ YOri{:} ]');

% remove non-compliant data
inds = find(cellfun(@(x)size(x,2), XOri) >100);
if ~isempty(inds)
    fprintf('******** Some non compliant data found\n');
end
XOri(inds) = [];
YOri(inds) = [];
