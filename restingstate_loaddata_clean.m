clear
addpath('/home/arno/eeglab');
eeglab; close;

% get XOri, XTest and XHold
folderout = '../child-mind-restingstate_v2';
fileNamesOpen   = dir(fullfile(folderout, '*_eyesopen.set'));

% FIGURE OUT THE STRING PROBLEM BELOW *****************

XOri = cell(1,length(fileNamesOpen));
YOri = cell(1,length(fileNamesOpen));
SOri = cell(1,length(fileNamesOpen));
for iFile = 1:length(fileNamesOpen)
    SOri{iFile} = fileNamesOpen(iFile).name(1:12);
    fileNameClosed = fullfile(folderout, [SOri{iFile} '_eyesclosed.set']);
    if exist(fileNameClosed, 'file')
        fprintf('Dataset %s\n', SOri{iFile});
        EEGOpen   = pop_loadset(fullfile(fileNamesOpen(iFile).folder, fileNamesOpen(iFile).name));
        EEGClosed = pop_loadset(fileNameClosed);
        if EEGOpen.pnts == 1500 && EEGClosed.pnts == 1500
            XData = {}; YData = {};
            for iTrial = 1:EEGOpen.trials
                XData{end+1} = EEGOpen.data(:,:,iTrial);
                YData{end+1} = [ EEGOpen.gender EEGOpen.age EEGOpen.handedness EEGOpen.eyesclosed iTrial ]; 
            end
            for iTrial = 1:EEGClosed.trials
                XData{end+1} = EEGClosed.data(:,:,iTrial);
                YData{end+1} = [ EEGClosed.gender EEGClosed.age EEGClosed.handedness EEGClosed.eyesclosed iTrial ]; 
            end
            XOri{iFile} = XData;
            YOri{iFile} = YData;
        end
    end
end
YOri(cellfun(@isempty, XOri)) = [];
SOri(cellfun(@isempty, XOri)) = [];
XOri(cellfun(@isempty, XOri)) = [];

if 0
    for iFile = 1:length(XOri)
        XData = XOri{iFile};
        YData = YOri{iFile};
        save('-mat', fullfile(folderout, [ SOri{iFile} '.mat']), 'XData', 'YData');
    end
end

% Concatenate
XOri = [ XOri{:} ]';
YOri = [ YOri{:} ]';
inds = find(cellfun(@ischar, YOri));
XOri(inds) = [];
YOri(inds) = [];

% remove non-compliant data
inds = find(cellfun(@(x)size(x,2), XOri) >1500);
if ~isempty(inds)
    error('******** Some non compliant data found\n');
    XOri(inds) = [];
    YOri(inds) = [];
end
