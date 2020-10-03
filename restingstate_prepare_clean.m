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
epochSize = 15;

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

% read the CSV file
info = loadtxt('HBN_all_Pheno.csv', 'delim', ',', 'verbose', 'off');
info = info(2:end,:);

XTrain = cell(1,length(folders));
YTrain = cell(1,length(folders));
issueFlag = cell(1, length(folders));
count = 1;
parfor iFold = 1:length(folders)
    %for iFold = 1:6 %length(folders)
    
    fileName = fullfile(folders(iFold).folder, folders(iFold).name, 'EEG/raw/mat_format/RestingState.mat');
    fileNameClosedSet = fullfile(folderout, [ folders(iFold).name '_eyesclosed.set' ]);
    fileNameClosedFdt = fullfile(folderout, [ folders(iFold).name '_eyesclosed.fdt' ]);
    fileNameOpenSet   = fullfile(folderout, [ folders(iFold).name '_eyesopen.set' ]);
    fileNameOpenFdt   = fullfile(folderout, [ folders(iFold).name '_eyesopen.fdt' ]);
    if exist(fileNameClosedSet, 'file')
        delete(fileNameClosedSet);
        delete(fileNameClosedFdt);
    end
    if exist(fileNameOpenSet, 'file')
        delete(fileNameOpenSet);
        delete(fileNameOpenFdt);
    end
    infoRow = strmatch(folders(iFold).name, info(:,1)', 'exact');
    if exist(fileName, 'file') && length(infoRow) > 0
        try
            EEG = load(fileName);
            EEG = EEG.EEG;
            
            if EEG.nbchan == 129
                for iEvent2 = 1:length(EEG.event)
                    EEG.event(iEvent2).latency = EEG.event(iEvent2).sample;
                end
                
                % copy info
                EEG.gender     = info{infoRow(1),2};
                EEG.age        = info{infoRow(1),3};
                EEG.handedness = info{infoRow(1),4};
                
                % get channel location and clean data
                EEG = pop_chanedit(EEG, 'load',{'GSN_HydroCel_129.sfp','filetype','autodetect'});
                EEG = pop_select(EEG, 'nochannel', 129);
                EEG = pop_rmbase(EEG, []);
                EEG = pop_eegfiltnew(EEG, 'locutoff',0.25,'hicutoff',50);
                EEG = pop_resample(EEG, 100);
                NEWEEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.7,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
                NEWEEG = pop_interp(NEWEEG, EEG.chanlocs);
                
                EEGeyeso = pop_epoch( NEWEEG, {  '20  ' }, [4  19], 'newname', 'Eyes open', 'epochinfo', 'yes');
                EEGeyeso.eyesclosed = 0;
                pop_saveset(EEGeyesc, fileNameOpenSet);
                
                EEGeyesc = pop_epoch( NEWEEG, {  '30  ' }, [4  19], 'newname', 'Eyes closed', 'epochinfo', 'yes');
                EEGeyesc.eyesclosed = 1;
                pop_saveset(EEGeyesc, fileNameClosedSet);
                
                
                % save epoched datasets as .set and .mat files
                EEG2 = pop_epoch( EEG, {  'EyesO'  }, [0 1], 'epochinfo', 'yes');
                EEG2.condition = 'eyeso';
                
                EEG3 = pop_epoch( EEG, {  'EyesC'  }, [0 1], 'epochinfo', 'yes');
                EEG3.condition = 'eyesc';
            else
                issueFlag{iFold} = 'Not 129 channels';
            end
        catch
            issueFlag{iFold} = lasterr;
        end
    end
end

indIssue = find(~cellfun(@isempty, issueFlag));
fprintf('Issues at indices (empty means no issues): %s\n', int2str(indIssue));
if ~isempty(indIssue), issueFlag(indIssue)', end
