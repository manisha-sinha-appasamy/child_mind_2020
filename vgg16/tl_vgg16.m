% load the data and network
load child_mind_spec.mat;
load vgg16.mat;

%net = vgg16;
numClasses = 2;
inputSize = net.Layers(1).InputSize;
lgraph = layerGraph(net.Layers);

% replace layers
newLearnableLayer = fullyConnectedLayer(numClasses, 'Name','new_fc', 'WeightLearnRateFactor',10, 'BiasLearnRateFactor',10);
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

% resize images
YFinal = categorical(cellfun(@(x)x(4), YOri));
ds = augmentedImageDatastore(inputSize,XOriSpec,YFinal);

%% options
miniBatchSize = 10;
valFrequency = floor(length(XOriSpec)/miniBatchSize);
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',6, ...
    'InitialLearnRate',3e-4, ...
    'Shuffle','every-epoch', ...
    'Verbose',false, ...
    'Plots','training-progress');
net = trainNetwork(ds,lgraph,options);

