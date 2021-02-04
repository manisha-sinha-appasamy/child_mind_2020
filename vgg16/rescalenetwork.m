function newlayers = rescalenetwork(layers, subsample, numClasses, dropLayers)

layers(dropLayers) = [];
newlayers = [];
for iLayer = 1:numel(layers)
    if isa(layers(iLayer),'nnet.cnn.layer.ImageInputLayer')
        InputSize = layers(iLayer).InputSize;
        newlayertmp = imageInputLayer([ InputSize(1)/subsample InputSize(2)/subsample InputSize(3)]);
    elseif isa(layers(iLayer),'nnet.cnn.layer.FullyConnectedLayer')
        if iLayer == numel(layers)-2
            newlayertmp = fullyConnectedLayer(numClasses);
        else
            newlayertmp = fullyConnectedLayer(ceil(layers(iLayer).OutputSize));
        end
    elseif isa(layers(iLayer),'nnet.cnn.layer.Convolution2DLayer')
        newlayertmp = convolution2dLayer(layers(iLayer).FilterSize, ...
            ceil(layers(iLayer).NumFilters), ...
            'Stride', layers(iLayer).Stride, ...
            'DilationFactor',  layers(iLayer).DilationFactor, ...
            'Padding', layers(iLayer).PaddingSize, ...
            'NumChannels', layers(iLayer).NumChannels);
    else
        newlayertmp = layers(iLayer);
    end
    newlayers = [ newlayers newlayertmp ];
end
