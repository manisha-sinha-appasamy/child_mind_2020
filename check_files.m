res = loadtxt('~/filelist.txt');

inds = strfind(res, '.tar.gz');
inds = cellfun(@(x)~isempty(x), inds);
res(inds) = [];

% find folders only
rmInd = [];
for iFile = 1:length(res)
    if ~exist(res{iFile}, 'dir') || length(res{iFile}) < 15 || ~isempty(strfind(res{iFile}, 'Contents'))
        rmInd = [ rmInd iFile ];
    end
end
res(rmInd) = [];      

% remove subject name and count
subjects = {};
for iFile = 1:length(res)
    subjects{end+1} = res{iFile}(3:15);
    res{iFile} = res{iFile}(16:end);
end
uniqS = unique(subjects);
uniq  = unique(res);

% remove parent folders
rmInd = [];
for iUniq = 1:length(uniq)
    if strcmpi(uniq{iUniq}, 'Behavioral') || strcmpi(uniq{iUniq}, 'EEG')  ...
            || strcmpi(uniq{iUniq}, 'EEG/raw') || strcmpi(uniq{iUniq}, 'Eyetracking') ... 
            || strcmpi(uniq{iUniq}, 'EEG/preprocessed') 
        rmInd = [ rmInd iUniq ];
    else
        % remove MFF subfolders
        if ~isempty(strfind(uniq{iUniq}, 'EEG/raw/mff_format')) && ~isequal(uniq{iUniq}(end), 't')
            rmInd = [ rmInd iUniq ];
        end
    end
end
uniq(rmInd) = [];

% display results
fprintf('%30s : %d\n', 'Number of subjects', length(uniqS) );
for iUniq = 1:length(uniq)
    inds = strmatch(uniq{iUniq}, res, 'exact');
    fprintf('%30s : %d\n', uniq{iUniq}, length(inds));
end

