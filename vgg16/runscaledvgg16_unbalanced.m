clear
load child_mind_spec.mat;

% remove NaNs
minval = nanmin(nanmin(XOriSpec,[],1),[],2);
maxval = nanmax(nanmax(XOriSpec,[],1),[],2);
XOriSpec = bsxfun(@rdivide, bsxfun(@minus, XOriSpec, minval), maxval-minval)*255;
XOriSpec(isnan(XOriSpec(:))) = 0;

layers = vgg16 ('Weights', 'none');

subsample = 8;
if 1
    layers2 = rescalenetwork(layers, [28 28 3], subsample, 2, [26:32]); % net1
    layers2 = rescalenetwork(layers, [28 28 3], 1, 2, [26:32]);         % net2
    layers2 = rescalenetwork(layers, [28 28 3], subsample, 2, [19:32]); % net3
    %layers2 = rescalenetwork(layers, [28 28 3], subsample, 2, [26:32]); % net4
else
    layers2 = [ imageInputLayer([ 28 28 3]) ...
        convolution2dLayer(3, 64) ...
        reluLayer() ...
        maxPooling2dLayer(2, 'Stride', 2) ...
        fullyConnectedLayer(2) ...
        softmaxLayer() ...
        classificationLayer ];
end

% set individuals
uniquePersonVal = cellfun(@(x)x(2)+x(3), YOri);
kid = [0;cumsum(diff(uniquePersonVal) ~= 0)];
%tmp = [kid uniquePersonVal]; tmp(1:20,:)
uniqueKid = unique(kid);

% select training and testing set
YFinal = categorical(cellfun(@(x)x(1), YOri)); % gender
rng(1);
kidInds = randperm(length(uniqueKid));

numTrain= ceil(length(uniqueKid)*0.8);
kidTrain = uniqueKid(1:numTrain);
indTrain = ismember(kid, kidTrain);
XTrain = XOriSpec(:,:,:,indTrain);
YTrain = YFinal(indTrain);

kidTest = uniqueKid(numTrain+1:end);
indTest = ismember(kid, kidTest);
XTest  = XOriSpec(:,:,:,indTest);
YTest  = YFinal(indTest);

dsTrain = augmentedImageDatastore([size(XTrain,1) size(XTrain,2) size(XTrain,3)],XTrain,YTrain);
dsTest  = augmentedImageDatastore([size(XTest,1)  size(XTest,2)  size(XTest,3)], XTest, YTest);

if 0
    % SVM performance
    XTrainSVM = reshape(XTrain, size(XTrain,1)*size(XTrain,2)*size(XTrain,3), size(XTrain,4))';
    XTestSVM  = reshape(XTest,  size(XTest,1) *size(XTest,2) *size(XTest,3),  size(XTest,4))';
    svm = fitcsvm(gpuArray(XTrainSVM),YTrain,'Standardize',true);
    labels = predict(svm, XTestSVM);
    perf = sum((labels==YTest))/length(labels); % 60% performance
elseif 0
    % Random forest 
    model2 = TreeBagger(100, XTrainSVM, YTrain, 'nprint', 20); % very fast
    labels = predict(model2, XTestSVM);
    perf = sum((labels==YTest))/length(labels); % 82% performance (not better with 1000 trees
elseif 0
    % logisit regression
    [B,FitInfo] = lassoglm(XTrainSVM, YTrain,'binomial','NumLambda',25, 'link','logit', 'CV', 3);
    idxLambdaMinDeviance = FitInfo.IndexMinDeviance;
    B0 = FitInfo.Intercept(idxLambdaMinDeviance);
    coef = [B0; B(:,idxLambdaMinDeviance)];
    yhat = glmval(coef,XTestSVM,'logit');
    yhatBinom = (yhat>=0.5);
    perf = sum(YTest == categorical(yhatBinom+0))/length(yhat); % 81% performance
end

%% options
miniBatchSize = 1024; % power of 2
valFrequency = floor(length(XOriSpec)/miniBatchSize);
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',180, ...
    'InitialLearnRate', 0.01, ... % 3e-4, Change learning schedule every 30 epochs, divide by 10
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, ...
    'LearnRateDropPeriod', 40, ... % or 30
    'ValidationData', dsTest, ...
    'ValidationFrequency', valFrequency, ...
    'Shuffle','every-epoch', ...
    'Verbose',false, ...
    'Plots','training-progress');
net = trainNetwork(dsTrain,layers2,options);