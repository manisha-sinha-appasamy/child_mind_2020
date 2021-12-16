%% load the network layers to be trained =======================

load('R-VGG.mat')
%deepNetworkDesigner

%% Pre-process Training data ===================================

% load training data
load('-mat','/expanse/projects/nemar/dtyoung/DL-EEG/data/child_mind_x_train_2s_24chan_raw.mat');
% load child_mind_x_train_2s_24chan_raw.mat % loads X_train

% load training labels
load('-mat','/expanse/projects/nemar/dtyoung/DL-EEG/data/child_mind_y_train_2s_24chan_raw.mat');
% load child_mind_all_labels_train_2s_24chan_raw.mat % loads Y_train

% labels must be categorical for the classification to work!
train_labels = categorical(Y_train); 

image_height = size(X_train,1);
image_width = size(X_train,2);
image_depth = 1;

% number of training samples (each sample = 24 x 256 size)
num_images = size(X_train,3);

imageSize = [image_height image_width image_depth];

% reshape the raw data to make it compatible for the image input layer
X_train = reshape(X_train,[imageSize,num_images]);

% training datastore: augimds
augimds = augmentedImageDatastore(imageSize,X_train,train_labels);


%% Pre-process Validation data ===================================

% load validation data
load('-mat','/expanse/projects/nemar/dtyoung/DL-EEG/data/child_mind_x_val_2s_24chan_raw.mat');
%load child_mind_x_val_1s_24chan_raw.mat % loads X_val

% load validation labels
load('-mat','/expanse/projects/nemar/dtyoung/DL-EEG/data/child_mind_y_val_2s_24chan_raw.mat');
%load child_mind_all_labels_val_2s_24chan_raw.mat % loads Y_val

% labels must be categorical for the classification to work!
val_labels = categorical(Y_val);

% num of validation samples
num_val = size(X_val,3); 

% reshape the raw data to make it compatible for the image input layer
X_val = reshape(X_val,[imageSize,num_val]);


%% training options ============================================

% options = trainingOptions('adam', ...
%     'InitialLearnRate',3e-4, ...
%     'SquaredGradientDecayFactor',0.9, ...
%     'MaxEpochs',20, ...
%     'MiniBatchSize',70, ...
%     'Plots','training-progress',...
%      'ValidationData',{X_val,val_labels});
% 
% Training on single GPU.
% Initializing input data normalization.
% |======================================================================================================================|
% |  Epoch  |  Iteration  |  Time Elapsed  |  Mini-batch  |  Validation  |  Mini-batch  |  Validation  |  Base Learning  |
% |         |             |   (hh:mm:ss)   |   Accuracy   |   Accuracy   |     Loss     |     Loss     |      Rate       |
% |======================================================================================================================|
% |       1 |           1 |       00:00:19 |       48.57% |       49.86% |       1.4963 |       3.9654 |          0.0003 |
% |       1 |          50 |       00:00:52 |       55.71% |       60.46% |       0.7756 |       0.7768 |          0.0003 |
% |       1 |         100 |       00:01:26 |       77.14% |       64.62% |       0.6961 |       0.7941 |          0.0003 |
% |       1 |         150 |       00:02:00 |       55.71% |       59.26% |       0.7975 |       0.7220 |          0.0003 |
% |       1 |         200 |       00:02:34 |       77.14% |       70.66% |       0.5766 |       0.7134 |          0.0003 |
% |       1 |         250 |       00:03:08 |       77.14% |       70.93% |       0.5117 |       0.6997 |          0.0003 |
% |       1 |         300 |       00:03:42 |       75.71% |       72.60% |       0.4942 |       0.6548 |          0.0003 |
% |       1 |         350 |       00:04:16 |       71.43% |       71.59% |       0.5458 |       0.6134 |          0.0003 |
% |       1 |         400 |       00:04:50 |       90.00% |       73.05% |       0.3779 |       0.5964 |          0.0003 |
% |       1 |         450 |       00:05:24 |       81.43% |       75.98% |       0.4145 |       0.5514 |          0.0003 |
% |       1 |         500 |       00:05:58 |       82.86% |       75.67% |       0.4556 |       0.5345 |          0.0003 |
% |       1 |         550 |       00:06:31 |       84.29% |       75.96% |       0.3571 |       0.5295 |          0.0003 |
% |       1 |         600 |       00:07:05 |       78.57% |       76.81% |       0.5103 |       0.5427 |          0.0003 |
% |       1 |         602 |       00:07:06 |       75.71% |              |       0.4825 |              |          0.0003 |
% |======================================================================================================================|
% Training finished: Stopped manually.




options = trainingOptions('adam', ...
    'InitialLearnRate',0.0005, ...
    'SquaredGradientDecayFactor',0.99, ...
    'MaxEpochs',20, ...
    'MiniBatchSize',70, ...
    'Plots','training-progress',...
     'ValidationData',{X_val,val_labels});

% Early stopping results
% Training on single GPU.
% Initializing input data normalization.
% |======================================================================================================================|
% |  Epoch  |  Iteration  |  Time Elapsed  |  Mini-batch  |  Validation  |  Mini-batch  |  Validation  |  Base Learning  |
% |         |             |   (hh:mm:ss)   |   Accuracy   |   Accuracy   |     Loss     |     Loss     |      Rate       |
% |======================================================================================================================|
% |       1 |           1 |       00:00:20 |       44.29% |       49.86% |       1.4812 |       2.9322 |          0.0005 |
% |       1 |          50 |       00:00:53 |       60.00% |       50.61% |       0.6682 |       0.7210 |          0.0005 |
% |       1 |         100 |       00:01:27 |       58.57% |       55.81% |       0.6626 |       0.7159 |          0.0005 |
% |       1 |         150 |       00:02:01 |       65.71% |       62.76% |       0.7165 |       0.7257 |          0.0005 |
% |       1 |         200 |       00:02:35 |       71.43% |       67.91% |       0.5833 |       0.6392 |          0.0005 |
% |       1 |         250 |       00:03:08 |       70.00% |       69.70% |       0.5497 |       0.6402 |          0.0005 |
% |       1 |         300 |       00:03:42 |       68.57% |       73.23% |       0.5850 |       0.5805 |          0.0005 |
% |       1 |         350 |       00:04:16 |       85.71% |       73.94% |       0.3355 |       0.5863 |          0.0005 |
% |       1 |         400 |       00:04:50 |       78.57% |       72.54% |       0.4549 |       0.5931 |          0.0005 |
% |       1 |         450 |       00:05:24 |       77.14% |       74.57% |       0.5083 |       0.5431 |          0.0005 |
% |       1 |         500 |       00:05:58 |       78.57% |       75.20% |       0.4213 |       0.5641 |          0.0005 |
% |       1 |         550 |       00:06:32 |       75.71% |       76.38% |       0.4167 |       0.5269 |          0.0005 |
% |       1 |         600 |       00:07:05 |       80.00% |       75.93% |       0.3884 |       0.5245 |          0.0005 |
% |       1 |         650 |       00:07:39 |       75.71% |       73.45% |       0.5278 |       0.5978 |          0.0005 |
% |       1 |         700 |       00:08:13 |       82.86% |       74.55% |       0.3517 |       0.5289 |          0.0005 |
% |       1 |         750 |       00:08:46 |       85.71% |       75.82% |       0.3788 |       0.5248 |          0.0005 |
% |       1 |         800 |       00:09:20 |       77.14% |       76.36% |       0.4367 |       0.5650 |          0.0005 |
% |       1 |         802 |       00:09:21 |       82.86% |              |       0.3710 |              |          0.0005 |
% |======================================================================================================================|
% Training finished: Stopped manually.


%% train the network =======================================================

net = trainNetwork(augimds,layers,options);

% Training on single GPU.
% Initializing input data normalization.
% |======================================================================================================================|
% |  Epoch  |  Iteration  |  Time Elapsed  |  Mini-batch  |  Validation  |  Mini-batch  |  Validation  |  Base Learning  |
% |         |             |   (hh:mm:ss)   |   Accuracy   |   Accuracy   |     Loss     |     Loss     |      Rate       |
% |======================================================================================================================|
% |       1 |           1 |       00:00:18 |       51.43% |       50.14% |       1.0009 |       3.3432 |          0.0005 |
% |       1 |          50 |       00:00:52 |       67.14% |       56.45% |       0.6793 |       0.7202 |          0.0005 |
% |       1 |         100 |       00:01:26 |       62.86% |       52.58% |       0.7379 |       0.7530 |          0.0005 |
% |       1 |         150 |       00:02:00 |       67.14% |       64.07% |       0.6374 |       0.7513 |          0.0005 |
% |       1 |         200 |       00:02:34 |       74.29% |       72.73% |       0.6500 |       0.6183 |          0.0005 |
% |       1 |         250 |       00:03:08 |       72.86% |       73.28% |       0.4839 |       0.5946 |          0.0005 |
% |       1 |         300 |       00:03:42 |       80.00% |       74.87% |       0.4320 |       0.5966 |          0.0005 |
% |       1 |         350 |       00:04:15 |       82.86% |       73.80% |       0.4057 |       0.5710 |          0.0005 |
% |       1 |         400 |       00:04:49 |       72.86% |       74.40% |       0.5143 |       0.5565 |          0.0005 |
% |       1 |         450 |       00:05:23 |       87.14% |       75.16% |       0.3780 |       0.5516 |          0.0005 |
% |       1 |         500 |       00:05:57 |       75.71% |       76.85% |       0.5762 |       0.5378 |          0.0005 |
% |       1 |         550 |       00:06:31 |       80.00% |       76.52% |       0.4069 |       0.5104 |          0.0005 |
% |       1 |         600 |       00:07:05 |       78.57% |       77.86% |       0.4483 |       0.4828 |          0.0005 |
% |       1 |         650 |       00:07:39 |       87.14% |       78.11% |       0.3452 |       0.4717 |          0.0005 |
% |       1 |         700 |       00:08:13 |       75.71% |       78.34% |       0.5130 |       0.5073 |          0.0005 |
% |       1 |         750 |       00:08:47 |       87.14% |       76.50% |       0.3137 |       0.5104 |          0.0005 |
% |       1 |         800 |       00:09:21 |       82.86% |       78.65% |       0.4430 |       0.5010 |          0.0005 |
% |       1 |         850 |       00:09:55 |       74.29% |       79.07% |       0.4195 |       0.5365 |          0.0005 |
% |       1 |         900 |       00:10:29 |       84.29% |       76.29% |       0.3658 |       0.5259 |          0.0005 |
% |       1 |         950 |       00:11:03 |       81.43% |       78.37% |       0.4331 |       0.5220 |          0.0005 |
% |       1 |        1000 |       00:11:37 |       81.43% |       77.56% |       0.3770 |       0.4973 |          0.0005 |
% |       1 |        1006 |       00:11:39 |       82.86% |              |       0.3870 |              |          0.0005 |
% |======================================================================================================================|
% Training finished: Stopped manually.


%% Pre-process Test data =========================================================
% load training data
load child_mind_x_test_2s_24chan_raw.mat % loads X_test

% load training labels
load child_mind_all_labels_test_2s_24chan_raw.mat % loads Y_test

% labels must be categorical for the classification to work!
test_labels = categorical(cell2mat(Y_test(:,2))); 

image_height = size(X_test,1);
image_width = size(X_test,2);
image_depth = 1;

imageSize = [image_height, image_width, image_depth];


% num of test samples
num_test = size(X_test,3);

% reshape the raw data to make it compatible for the image input layer
X_test = reshape(X_test,[imageSize,num_test]);

% test datastore: test_imds
test_imds = augmentedImageDatastore(imageSize,X_test,test_labels);

%% test the trained network =======================================================

Y_pred = classify(net,test_imds);
% Y_pred_label = test_imds.Labels;

%% Test accuracy ==================================================================
correct = 0;
for i = 1 : num_test
    if(Y_pred(i)==test_labels(i))
        correct = correct+1;
    end
end


test_accuracy = 100*correct/num_test;



% test_accuracy =
% 
%    77.5385
