res = loadtxt('~/filelist2.txt', 'verbose', 'off', 'convert', 'off');
disp('Pass 1')

inds = strfind(res, '.tar.gz');
inds = cellfun(@(x)~isempty(x), inds);
res(inds) = [];
disp('Pass 2')

inds = strfind(res, 'Contents');
inds = cellfun(@(x)~isempty(x), inds);
res(inds) = [];
disp('Pass 2.2');

inds = strfind(res, 'ideo');
inds = cellfun(@(x)~isempty(x), inds);
res = res(inds);

% find folders only
rmInd = [];
for iFile = 1:length(res)
    if length(res{iFile}) < 15  % || ~exist(res{iFile}, 'dir')
        rmInd = [ rmInd iFile ];
    end
end
res(rmInd) = [];      
disp('Pass 3')

% remove subject name and count
subjects = {};
for iFile = 1:length(res)
    subjects{end+1} = res{iFile}(3:15);
    res{iFile} = res{iFile}(16:end);
end
uniqS = unique(subjects);
uniq  = unique(res);
disp('Pass 4')

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
disp('Pass 5')

% display results
sStr = {};
sVal = []; 
for iUniq = 1:length(uniq)
    inds = strmatch(uniq{iUniq}, res, 'exact');
    sStr{iUniq} = uniq{iUniq};
    sVal(iUniq) = length(inds);
end
disp('Pass 6')

fprintf('%30s : %d\n', 'Number of subjects', length(uniqS) );
[sVal,iOrder] = sort(sVal, 'descend');
sStr = sStr(iOrder);
for iUniq = 1:length(uniq)
    fprintf('%30s : %d\n', sStr{iUniq}, sVal(iUniq));
end

