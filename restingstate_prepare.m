% Issues at indices (empty means no issues): 124   216   253   304   405   525   593   620   627   787   824   931   956  1180  1334  1341  1384  1477  1524  1702  1721  1884  1968  2326  2423  2456  2528
% 
% ans =
% 
%   27×1 cell array
% 
%     {'Not 129 channels'                                                                       }
%     {'Less eyes closed than eyes open'                                                        }
%     {'Error using pop_epoch (line 261)?pop_epoch(): empty epoch range (no epochs were found).'}
%     {'Less eyes closed than eyes open'                                                        }
%     {'Less eyes closed than eyes open'                                                        }
%     {'Less eyes closed than eyes open'                                                        }
%     {'Less eyes closed than eyes open'                                                        }
%     {'Less eyes closed than eyes open'                                                        }
%     {'Error using pop_epoch (line 261)?pop_epoch(): empty epoch range (no epochs were found).'}
%     {'Error using pop_epoch (line 261)?pop_epoch(): empty epoch range (no epochs were found).'}
%     {'Less eyes closed than eyes open'                                                        }
%     {'Reference to non-existent field 'EEG'.'                                                 }
%     {'Less eyes closed than eyes open'                                                        }
%     {'Less eyes closed than eyes open'                                                        }
%     {'Less eyes closed than eyes open'                                                        }
%     {'Less eyes closed than eyes open'                                                        }
%     {'Less eyes closed than eyes open'                                                        }
%     {'Less eyes closed than eyes open'                                                        }
%     {'Less eyes closed than eyes open'                                                        }
%     {'Reference to non-existent field 'EEG'.'                                                 }
%     {'Less eyes closed than eyes open'                                                        }
%     {'Less eyes closed than eyes open'                                                        }
%     {'Not 129 channels'                                                                       }
%     {'Less eyes closed than eyes open'                                                        }
%     {'Less eyes closed than eyes open'                                                        }
%     {'Less eyes closed than eyes open'                                                        }
%     {'Reference to non-existent field 'EEG'.'     

clear

% Path to data
folderin  = '../child-mind-uncompressed';
folderout = '../child-mind-restingstate';
folders = dir(folderin);

% Prepare data
fileTrain = dir(fullfile(folderout, '*.set'));
if ~isempty(fileTrain)
    s = input('Are you sure you want to delete the training data (CRTL-C to stop; enter to continue)', 's');
end

% Add EEGLAB path
addpath('/home/arno/eeglab');
if isempty(which('eeg_checkset.m'))
    eeglab; close;
end


XTrain = cell(1,length(folders));
YTrain = cell(1,length(folders));
issueFlag = cell(1, length(folders));
count = 1;
parfor iFold = 1:length(folders)
%for iFold = 1:6 %length(folders)
    
    fileName = fullfile(folders(iFold).folder, folders(iFold).name, 'EEG/raw/mat_format/RestingState.mat');
    fileNameOut = fullfile(folderout, [ folders(iFold).name '_reststate.set' ]);
    fileNameOut2 = fullfile(folderout, [ folders(iFold).name '_reststate.fdt' ]);
    if exist(fileNameOut, 'file')
        delete(fileNameOut);
        delete(fileNameOut2);
    end
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
            
            if EEG3.trials > EEG2.trials
                if EEG.nbchan == 129
                    keepTrials = ceil(linspace(1, EEG3.trials, EEG2.trials));
                    EEG3 = pop_select(EEG3, 'trial', keepTrials);

                    EEG4 = pop_mergeset(EEG2, EEG3);
                    pop_saveset(EEG4, fileNameOut);
                else
                    issueFlag{iFold} = 'Not 129 channels';
                end
            else
                issueFlag{iFold} = 'Less eyes closed than eyes open';
            end
        catch
            issueFlag{iFold} = lasterr;
        end
    end
end

indIssue = find(~cellfun(@isempty, issueFlag));
fprintf('Issues at indices (empty means no issues): %s\n', int2str(indIssue));
if ~isempty(indIssue), issueFlag(indIssue)', end
