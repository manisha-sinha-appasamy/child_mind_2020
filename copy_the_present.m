folderin = '.';
folderout = '../child-mind-TP';

folders = dir(folderin);

for iFolder = 1:length(folders)
    
    fullPath = fullfile(folders(iFolder).folder, folders(iFolder).name);
    if exist(fullPath, 'dir')
        msg = '';
        movieOrder      = dir(fullfile(fullPath, 'Behavioral', 'mat_format', '*movie_order.mat'));
        movieTP         = dir(fullfile(fullPath, 'EEG', 'raw', 'mat_format', 'Video-TP.mat'));
        movieAll        = dir(fullfile(fullPath, 'EEG', 'raw', 'mat_format', 'Video*.mat'));
        movieWithNames  = dir(fullfile(fullPath, 'EEG', 'raw', 'mat_format', 'Video-*.mat'));
        
        if isempty(movieWithNames) && isempty(movieAll)
            msg = 'No movie with EEG';
        elseif ~isempty(movieWithNames) && any(cellfun(@length, { movieAll.name }) < 11)
            msg = 'Two types of movies (number and names) - ERROR';
        elseif ~isempty(movieWithNames)
            if ~isempty(movieTP)
                msg = 'Movie TP found - name';
            else
                msg = 'No movie TP with other movies with name (EEG) present';
            end
        else % ~isempty(movieAll)
            for iMovie = 1:length(movieAll)
                EEG = load('-mat', fullfile(movieAll(iMovie).folder, movieAll(iMovie).name));
                if ~isempty(fieldnames(EEG))
			types = { EEG.EEG.event(1:min(3, length(EEG.EEG.event))).type };
                	if ~isempty(strmatch('84', types))
				if isempty(movieTP)
                    			movieTP = movieAll(iMovie);
				else
					error('Two movies with event 84');
				end
                	end
		end
            end
            if isempty(movieTP)
                msg = 'No movie TP with other movies with number (EEG) present';
            else
                msg = 'Movie TP found - number';
	    end
        end
        
        %         tmpOrder = load('-mat', fullfile(movieOrder(1).folder, movieOrder(1).name));
        %         movieList = tmpOrder.movie_presentation_order;
        %         if ~isempty(movieList)
        %             if length(movieOrder) > 1
        %                 tmpOrder = load('-mat', fullfile(movieOrder(2).folder, movieOrder(2).name));
        %                 movieList = tmpOrder.movie_presentation_order;
        %             end
        %         end
        %         for iMovie = 1:length(movieList)
        %             if iscell(movieList{iMovie})
        %                 movieList{iMovie} = movieList{iMovie}{1};
        %             end
        %         end
        %         movieMember = ismember(movieList, '/Clips/The_Present.mp4');
        %         if any(movieMember)
        %             msg = sprintf('Movie found at position %d', movieMember);
        %             movieTP  = dir(fullfile(fullPath, 'EEG', 'raw', 'mat_format', sprintf('Video%d.mat', movieMember)));
        %         end
        
        fprintf('%s: %s\n', folders(iFolder).name, msg);

        if ~isempty(movieTP)
		if length(movieTP.name) <= 10
			movieTPeyeEvents  = dir(fullfile(fullPath, 'Eyetracking', 'txt', [ '*_' movieTP.name(1:6) '*Events.txt' ]));
                        movieTPeyeSamples = dir(fullfile(fullPath, 'Eyetracking', 'txt', [ '*_' movieTP.name(1:6) '*Samples.txt' ]));
		else
		       	movieTPeyeEvents  = dir(fullfile(fullPath, 'Eyetracking', 'txt', [ '*_' movieTP.name(1:8) '*Events.txt' ]));
                        movieTPeyeSamples = dir(fullfile(fullPath, 'Eyetracking', 'txt', [ '*_' movieTP.name(1:8) '*Samples.txt' ]));
		end
		if length(movieTPeyeEvents) ~= 1 || length(movieTPeyeSamples) ~= 1
		        msg = [ msg ' - Cannot find eye tracking file' ];
		else
			% copy files
			folderSubject = fullfile(folderout, folders(iFolder).name);
			mkdir(folderSubject);
			copyfile(fullfile(movieTP.folder, movieTP.name),                           fullfile(folderSubject, 'Video-TP.mat'));
			copyfile(fullfile(movieTPeyeEvents(1).folder , movieTPeyeEvents(1).name ), fullfile(folderSubject, 'Video1_Events.txt'));
                        copyfile(fullfile(movieTPeyeSamples(1).folder, movieTPeyeSamples(1).name), fullfile(folderSubject, 'Video1_Samples.txt'));
		end
	end
        fprintf('%s: %s\n', folders(iFolder).name, msg);

    end
end

