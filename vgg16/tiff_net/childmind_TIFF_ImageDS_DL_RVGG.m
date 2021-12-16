mkdir test
mkdir train
mkdir val

%% load the network layers to be trained

load('R-VGG_noNormalization.mat')
%deepNetworkDesigner

%% Pre-process Training data

% load training data
load('-mat','/expanse/projects/nemar/dtyoung/DL-EEG/data/child_mind_x_train_2s_24chan_raw.mat');

% load training labels
load('-mat','/expanse/projects/nemar/dtyoung/DL-EEG/data/child_mind_y_train_2s_24chan_raw.mat');

% Create folders where the images will be saved. The foldernames will serve as labels.
cd train;
train_labels = string(Y_train);
train_foldernames = unique(train_labels);;
if ~exist(train_foldernames(1),'dir')
    cellfun(@mkdir,train_foldernames);
end

% number of training samples (each sample = 24 x 256 size)
num_train = size(X_train,3);

% convert training samples to tiff images
mat2tiff(X_train,train_labels,num_train)
cd ..

%% training datastore: train_imds
train_imds = imageDatastore('train',...
"IncludeSubfolders",true,"FileExtensions",".tif","LabelSource","foldernames");


%% Pre-process Validation data

% load validation data
load child_mind_x_val_2s_24chan_raw.mat % loads X_val

% load validation labels
load child_mind_all_labels_val_2s_24chan_raw.mat % loads Y_val

% Create folders where the images will be saved. The foldernames will serve as labels.
cd val;
val_labels = string(Y_val(:,2));
val_foldernames = string(unique(cell2mat(Y_val(:,2))));
if ~exist(val_foldernames(1),'dir')
    cellfun(@mkdir,val_foldernames);
end


% num of validation samples
num_val = size(X_val,3); 

% convert validation samples to tiff images
mat2tiff(X_val,val_labels,num_val)
cd ..

%% Validation datastore: val_imds
val_imds = imageDatastore('val',...
"IncludeSubfolders",true,"FileExtensions",".tif","LabelSource","foldernames");




%% training options


options = trainingOptions('adam', ...
    'InitialLearnRate',0.0005, ...
    'SquaredGradientDecayFactor',0.99, ...
    'MaxEpochs',20, ...
    'MiniBatchSize',70, ...
    'Plots','training-progress',...
     'ValidationData',val_imds);



%% train the network

tiff_net = trainNetwork(train_imds,layers,options);

% Training on single GPU.
% |======================================================================================================================|
% |  Epoch  |  Iteration  |  Time Elapsed  |  Mini-batch  |  Validation  |  Mini-batch  |  Validation  |  Base Learning  |
% |         |             |   (hh:mm:ss)   |   Accuracy   |   Accuracy   |     Loss     |     Loss     |      Rate       |
% |======================================================================================================================|
% |       1 |           1 |       00:00:56 |       44.29% |       50.15% |       1.2143 |       1.9437 |          0.0005 |
% |       1 |          50 |       00:02:29 |       55.71% |       51.82% |       0.6909 |       0.7110 |          0.0005 |
% |       1 |         100 |       00:03:57 |       52.86% |       60.45% |       0.6781 |       0.7265 |          0.0005 |
% |       1 |         150 |       00:05:40 |       70.00% |       61.81% |       0.6392 |       0.7193 |          0.0005 |
% |       1 |         200 |       00:07:27 |       54.29% |       60.36% |       0.6848 |       0.7320 |          0.0005 |
% |       1 |         250 |       00:08:59 |       65.71% |       70.58% |       0.6053 |       0.6268 |          0.0005 |
% |       1 |         300 |       00:10:34 |       80.00% |       72.51% |       0.4744 |       0.5956 |          0.0005 |
% |       1 |         350 |       00:12:02 |       81.43% |       72.70% |       0.4493 |       0.6074 |          0.0005 |
% |       1 |         400 |       00:13:30 |       77.14% |       73.38% |       0.4775 |       0.5731 |          0.0005 |
% |       1 |         450 |       00:14:56 |       78.57% |       74.92% |       0.3982 |       0.5894 |          0.0005 |
% |       1 |         451 |       00:14:57 |       80.00% |              |       0.5647 |              |          0.0005 |
% |======================================================================================================================|
% Training finished: Stopped manually.


%% Pre-process Test data
% load training data
load child_mind_x_test_2s_24chan_raw.mat % loads X_test

% load training labels
load child_mind_all_labels_test_2s_24chan_raw.mat % loads Y_test

% Create folders where the images will be saved. The foldernames will serve as labels

cd test
test_labels = string(Y_test(:,2));
test_foldernames = string(unique(cell2mat(Y_test(:,2))));
if ~exist(test_foldernames(1),'dir')
    cellfun(@mkdir,test_foldernames);
end


% num of test samples
num_test = size(X_test,3);

% Convert test samples to tif files
mat2tiff(X_test,test_labels,num_test)

cd ..

%% test datastore: test_imds
test_imds = imageDatastore('test',...
"IncludeSubfolders",true,"FileExtensions",".tif","LabelSource","foldernames");

%% test the trained network

Y_pred = classify(tiff_net,test_imds);
% Y_pred_label = test_imds.Labels;

%% Test accuracy
correct = 0;
for i = 1 : num_test
    if(Y_pred(i)==test_imds.Labels(i))
        correct = correct+1;
    end
end


test_accuracy = 100*correct/num_test;



% test_accuracy =
% 
%    75.4851
