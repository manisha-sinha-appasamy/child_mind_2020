sAll = { 'NDARZZ830JM7' 'NDARNT898ZPF' 'NDARWA102TY7' }
sAll = { 'NDARFR873KZX' 'NDARVV704MND' 'NDARZE685UJ5' 'NDARND604TNB' 'NDARTV296UNC' 'NDARHP705RFA' 'NDARNV124WR8' 'NDARLR924YAV' 'NDARCM050BN2' 'NDARCR743RHQ' 'NDARVJ687ENB' };
for iS = 1:length(sAll)
	s = sAll{iS};
	fprintf('mkdir %s\n', s);
	fprintf('cd %s\n', s);
	fprintf('cp /projects/ps-nemar/child-mind-uncompressed/%s/EEG/raw/mat_format/Video-TP.mat ./EEG-Video-TP.mat\n', s);
	fprintf('cp /projects/ps-nemar/child-mind-uncompressed/%s/Eyetracking/txt/%s_Video-TP_Events.txt ./Eyetracking-Video-TP_Events.mat\n', s, s);
	fprintf('cp /projects/ps-nemar/child-mind-uncompressed/%s/Eyetracking/txt/%s_Video-TP_Samples.txt ./Eyetracking-Video-TP_Samples.mat\n', s, s);
	fprintf('cd ..\n', s);
end
