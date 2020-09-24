folderin = '.';
folderout = '/projects/ps-nemar/child-mind-Rest';
folders = dir(folderin);

for iFolder = 1:length(folders)
	filenameIn = fullfile(folders(iFolder).folder, folders(iFolder).name, 'EEG/raw/mat_format/RestingState.mat');
    	if exist(filenameIn, 'file')
		filenameOut = fullfile(folderout, folders(iFolder).name,'RestingState.mat');
		mkdir(fullfile(folderout, folders(iFolder).name);
		copyfile(filenameIn, filenameOut);
    	end
end
