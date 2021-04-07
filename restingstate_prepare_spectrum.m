% function restingstate_prepare_spectrum
restingstate_loaddata_clean;

EEG = EEGOpen;
freqRanges = [4 7; 7 13; 14 30]; % frequencies, but also indices
topoAll = cell(1, length(XOri));
parfor iX = 1:length(XOri)
    
    % compute spectrum
    [XSpecTmp,freqs] = spectopo(XOri{iX}, 1500, 100, 'plot', 'off', 'overlap', 50);
    XSpecTmp(:,1) = []; % remove frequency 0
    
    % get frequency bands
    theta = mean(XSpecTmp(:, freqRanges(1,1):freqRanges(1,2)), 2);
    alpha = mean(XSpecTmp(:, freqRanges(2,1):freqRanges(2,2)), 2);
    beta  = mean(XSpecTmp(:, freqRanges(3,1):freqRanges(3,2)), 2);
    
    % get grids
    [~, gridTheta] = topoplot( theta, EEG.chanlocs, 'verbose', 'off', 'gridscale', 28, 'noplot', 'on', 'chaninfo', EEG(1).chaninfo);
    [~, gridAlpha] = topoplot( alpha, EEG.chanlocs, 'verbose', 'off', 'gridscale', 28, 'noplot', 'on', 'chaninfo', EEG(1).chaninfo);
    [~, gridBeta ] = topoplot( beta , EEG.chanlocs, 'verbose', 'off', 'gridscale', 28, 'noplot', 'on', 'chaninfo', EEG(1).chaninfo);
    gridTheta = gridTheta(end:-1:1,:); % for proper imaging using figure; imagesc(grid);
    gridAlpha = gridAlpha(end:-1:1,:); % for proper imaging using figure; imagesc(grid);
    gridBeta  = gridBeta( end:-1:1,:); % for proper imaging using figure; imagesc(grid);
    
    % transform to RGB image
    topoTmp = gridTheta;
    topoTmp(:,:,3) = gridBeta;
    topoTmp(:,:,2) = gridAlpha;
    topoAll{iX} = single(topoTmp);
end

XOriSpec = cat(4, topoAll{:});

save('-mat', '-v6', '/expanse/projects/nemar/child_mind_2020/vgg16/child_mind_spec.mat', 'XOriSpec', 'YOri');
