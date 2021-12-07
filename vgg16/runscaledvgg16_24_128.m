clear

XTrain = load('-mat','../../dung_DL-EEG/child_mind_x_train.mat');
YTrain = load('-mat','../../dung_DL-EEG/child_mind_y_train.mat');
XTest  = load('-mat','../../dung_DL-EEG/child_mind_x_test.mat');
YTest  = load('-mat','../../dung_DL-EEG/child_mind_y_test.mat');

XTrain = XTrain.X_train;
YTrain = YTrain.Y_train;
XTest  = XTest.X_test;
YTest  = YTest.Y_test;

dsTrain = augmentedImageDatastore([size(XTrain,1) size(XTrain,2) size(XTrain,3)],XTrain,YTrain);
dsTest  = augmentedImageDatastore([size(XTest,1)  size(XTest,2)  size(XTest,3)], XTest, YTest);

layers2 = [ imageInputLayer([ 24 256]) ...
        convolution2dLayer(3, 64) ...
        reluLayer() ...
        maxPooling2dLayer(2, 'Stride', 2) ...
        fullyConnectedLayer(2) ...
        softmaxLayer() ...
        classificationLayer ];

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
miniBatchSize = 64; % power of 2
valFrequency = floor(length(XTrain)/miniBatchSize);
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

save('-mat', 'net.mat', 'net');
