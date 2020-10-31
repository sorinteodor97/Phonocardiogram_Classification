addpath('C:\Users\Buia Sorin\Desktop\Projects\Phonocardiogram-classification\Data processing\Helper Functions') %Functions folder
% Loading the data
    PCG_data = fileDatastore(fullfile('C:\Users\Buia Sorin\Desktop\Projects\Phonocardiogram-classification\Data processing', 'Raw_Data_PCG'), 'ReadFcn', @importAudioFile, 'FileExtensions', '.wav', 'IncludeSubfolders', 1);
    load('Label_Table');
%% 
% Features extraction
    Features_Tabel = table();
    Features_Tabel = [Features_Tabel; feature_extraction(PCG_data, Label_Table)];   
    save('Features_Tabel', 'Features_Tabel');
%%  
    % Relevant features selection
    mdl = fscnca(table2array(Features_Tabel(:,1:33)), ...
        table2array(Features_Tabel(:,34)), 'Lambda', 0.0005, 'Verbose', 0); 
    Relevant_Features = find(mdl.FeatureWeights > 0.1);  

    Selected_Features_Tabel = [Features_Tabel(:,Relevant_Features) Features_Tabel(:,34)];
save('Selected_Features_Tabel','Selected_Features_Tabel');
%% 
%   Split the data in training and testing
rng(1)
Data = cvpartition(Features_Tabel.class, 'Holdout', 0.3);
Training = Features_Tabel(Data.training, :);
Testing = Features_Tabel(Data.test,:);
%% 
%   Adding a cost function to reduce the False negative rate
C = [0, 10; 1, 0];
rng(1);
%   Setting the parameters for automatic optimization
cvp = cvpartition(height(Training),'KFold',5);
opts = struct('Optimizer','bayesopt','ShowPlots',true,'CVPartition',cvp,...
    'AcquisitionFunctionName','expected-improvement-plus');
%   Creating the model
Optimized_Model = fitcensemble(Training,'class','Cost',C,...
        'OptimizeHyperparameters',{'Method','NumLearningCycles','LearnRate'},...
        'HyperparameterOptimizationOptions',opts);
save('Optimized_Model', 'Optimized_Model');
%% 
% Prediction and performance
Prediction = predict(Optimized_Model,Testing);
ConfMatrix = confusionmat(Testing.class, Prediction);
ConfMatrixP = ConfMatrix*100./sum(ConfMatrix, 2);
Notatii = {'Abnormal', 'Normal'};
heatmap(Notatii, Notatii, ConfMatrixP, 'Colormap', winter, 'ColorbarVisible','off');
