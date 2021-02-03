tmp = load('-mat', 'WISC_ProcSpeed.mat');
tmp = load('-mat', 'SurroundSupp_Block1.mat');
EEG = tmp.EEG;

eeg_eventtypes(EEG)

res      = { EEG.event.type }';
res(:,2) = mattocell([EEG.event.sample])';
res(2:end,3) = mattocell(diff([EEG.event.sample]))'

for iEvent = 1:size(res,1)
    fprintf('%10s\t%d\t%d\n', res{iEvent,1}, res{iEvent,2}, res{iEvent,3})
end
