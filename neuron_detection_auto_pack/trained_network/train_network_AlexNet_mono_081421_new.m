% simple cnn for classification
patch_size=[56,56,3];

layers = [
    imageInputLayer(patch_size)
     
    convolution2dLayer(3,14*14,'Padding','same','Stride',4)
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'Stride',2)
        
    convolution2dLayer(3,7*7,'Padding','same','Stride',1)
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'Stride',2)
    
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer
    ];


imds = imageDatastore('D:\031622_ginny_autodetection_latest_method\trainingSet', ...
    'IncludeSubfolders',true,'LabelSource','foldernames');

numTrainFiles = 900;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');

options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.001, ...
    'MaxEpochs',10, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress',...
    'ExecutionEnvironment','cpu');

net = trainNetwork(imdsTrain,layers,options);

YPred = classify(net,imds);
YValidation = imds.Labels;

accuracy = sum(YPred == YValidation)/numel(YValidation);


