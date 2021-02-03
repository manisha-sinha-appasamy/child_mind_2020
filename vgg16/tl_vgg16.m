% load the data and network
load child_mind_spec.mat;
load vgg16.mat;

%net = vgg16;
numClasses = 2;
inputSize = net.Layers(1).InputSize;
lgraph = layerGraph(net.Layers);

% replace layers
newLearnableLayer = fullyConnectedLayer(numClasses, 'Name','new_fc');
lgraph = replaceLayer(lgraph,'fc8',newLearnableLayer);
newClassLayer = classificationLayer('Name','new_classoutput');
lgraph = replaceLayer(lgraph,'output',newClassLayer);
layers = lgraph.Layers;
connections = lgraph.Connections;

% This command does not work
if 0
    addpath('/Users/arno/Documents/MATLAB/Examples/R2020a/nnet/TransferLearningUsingGoogLeNetExample');
    layers(1:38) = freezeWeights(layers(1:38));
    lgraph = createLgraphUsingConnections(layers,connections);
else
    % Instead do it layer by layer manually
    for iLayer = 1:38
        if isprop(layers(iLayer), 'WeightLearnRateFactor')
            layers(iLayer).WeightLearnRateFactor = 0;
            layers(iLayer).BiasLearnRateFactor   = 0;
        end
    end
    lgraph = layerGraph();
    for i = 1:numel(layers)
        lgraph = addLayers(lgraph,layers(i));
    end
    for c = 1:size(connections,1)
        lgraph = connectLayers(lgraph,connections.Source{c},connections.Destination{c});
    end
end

YFinal = categorical(cellfun(@(x)x(4), YOri)); % eyes open/closed

% compare categories
if 0
    uniqueCat = unique(YFinal);
    nCat = length(uniqueCat);
    figure;
    for iCat = 1:nCat
        avgAct = mean(XOriSpec(:,:,:,YFinal==uniqueCat(iCat)),4);
        avgAct = bsxfun(@minus, avgAct, nanmin(nanmin(avgAct,[],2),[],1));
        maxAct = nanmax(avgAct(:));
        avgAct(isnan(avgAct(:))) = maxAct;
        thetaAct = avgAct; thetaAct(:,:,2:3) = maxAct;   thetaAct(:,:,2) = thetaAct(:,:,1);
        alphaAct = avgAct; alphaAct(:,:,[1 3]) = maxAct; alphaAct(:,:,3) = alphaAct(:,:,2);
        betaAct  = avgAct; betaAct( :,:,1:2) = maxAct;   betaAct( :,:,1) = betaAct( :,:,3);
        
        subplot(3,nCat,(1-1)*2+iCat); imagesc(thetaAct/maxAct); axis equal; axis off; title(sprintf('Theta - Cat %1.0f', uniqueCat(iCat)));
        subplot(3,nCat,(2-1)*2+iCat); imagesc(alphaAct/maxAct); axis equal; axis off; title(sprintf('Alpha - Cat %1.0f', uniqueCat(iCat)));
        subplot(3,nCat,(3-1)*2+iCat); imagesc(betaAct /maxAct); axis equal; axis off; title(sprintf('Beta  - Cat %1.0f', uniqueCat(iCat)));
        
    end
end

% remove NaNs
minval = nanmin(nanmin(XOriSpec,[],1),[],2);
maxval = nanmax(nanmax(XOriSpec,[],1),[],2);
XOriSpec = bsxfun(@rdivide, bsxfun(@minus, XOriSpec, minval), maxval-minval)*255;
XOriSpec(isnan(XOriSpec(:))) = 0;

% randomly select 2000 images
if 0
    rng('default')
    rng(0);
    ind = shuffle([1:length(YFinal)]);
    XOriSpec = XOriSpec(:,:,:,ind(1:1000));
    YFinal = YFinal(1:1000);
end

% resize images
ds = augmentedImageDatastore(inputSize,XOriSpec,YFinal);

%% options
miniBatchSize = 50;
valFrequency = 50; % floor(length(XOriSpec)/miniBatchSize);
options = trainingOptions('sgdm', ...
    'MiniBatchSize', miniBatchSize, ...
    'MaxEpochs',1000, ...
    'InitialLearnRate',0.00001, ...
    'ExecutionEnvironment', 'gpu',...
    'Shuffle','every-epoch', ...
    'Verbose',true, ...
    'ValidationData', ds, ...
    'ValidationFrequency', valFrequency, ...
    'VerboseFrequency', 50, ...
    'Plots','training-progress');
net = trainNetwork(ds,lgraph,options);

