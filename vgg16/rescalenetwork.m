function newlayers = rescalenetwork(layers, inputsize, subsample, numClasses, dropLayers)

layers(dropLayers) = [];
newlayers = [];
WeightL2Factor = 1;
BiasL2Factor = 0;
for iLayer = 1:numel(layers)
    if isa(layers(iLayer),'nnet.cnn.layer.ImageInputLayer')
        newlayertmp = imageInputLayer(inputsize);
    elseif isa(layers(iLayer),'nnet.cnn.layer.FullyConnectedLayer')
        if iLayer == numel(layers)-2
            newlayertmp = fullyConnectedLayer(numClasses, 'WeightL2Factor', WeightL2Factor, 'BiasL2Factor', BiasL2Factor);
        else
            newlayertmp = fullyConnectedLayer(ceil(layers(iLayer).OutputSize/subsample), 'WeightL2Factor', WeightL2Factor, 'BiasL2Factor', BiasL2Factor);
        end
    elseif isa(layers(iLayer),'nnet.cnn.layer.Convolution2DLayer')
        newlayertmp = convolution2dLayer(layers(iLayer).FilterSize, ...
            ceil(layers(iLayer).NumFilters/subsample), ...
            'Stride', layers(iLayer).Stride, ...
            'DilationFactor',  layers(iLayer).DilationFactor, ...
            'Padding', layers(iLayer).PaddingSize, ...
            'NumChannels', layers(iLayer).NumChannels, ...
            'BiasL2Factor', BiasL2Factor, ...
            'WeightL2Factor', WeightL2Factor);
    else
        newlayertmp = layers(iLayer);
    end
    newlayers = [ newlayers newlayertmp ];
end
