EEGfiles = dir('child-mind-TP/*/EEG*');

for iFile = 1:length(EEGfiles)
    tmp = load('-mat', fullfile(EEGfiles(iFile).folder, EEGfiles(iFile).name));
    [~,subject] = fileparts(EEGfiles(iFile).folder);
    latDiff = (EEG.event(3).sample-EEG.event(2).sample)/EEG.srate;
    fprintf('%s (%d events): %2.2f seconds\n', subject, length(EEG.event), latDiff);
end
