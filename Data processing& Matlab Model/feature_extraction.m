function Features_Tabel = feature_extraction(data,Label_Table)
warning off
Features_Tabel = table();

LabelMap = containers.Map('KeyType','int32','ValueType','char');
keySet = {-1, 1};
valueSet = {'Normal','Abnormal'};
LabelMap = containers.Map(keySet,valueSet);

    % Reading the data from the datastore.
while hasdata(data)
    FCG = read(data);
    signal = FCG.data;
    fs = FCG.fs;
    Label = Label_Table(strcmp(Label_Table.Signal_name, FCG.filename), :).Label;
    
    % Normalize signal value between -1 and 1.
    Normalised=(signal./max(signal));
    
    % Filter the signal noise.
    LowPass=butterworth_low_pass_filter(Normalised,2,600,2000);
    HighPass=butterworth_high_pass_filter(LowPass,2,25,2000);
   
    Pfilt60signal=Pfilt60(HighPass,2000);
    Pfilt50signal=Pfilt50(Pfilt60signal,2000);
    
% Using signal's energy in which S1 sound can be considered the
% significant peak to extract the cardiac cycle.
    Energy=(Pfilt50signal).^2;
    [pks,locs]=findpeaks(Energy,'MinPeakDistance',1000,'MinPeakHeight',0.15);
    
% Extract features from each cardiac cycle
     
    rowsToDelete = locs < 500;
    locs(rowsToDelete) = [];
    pks(rowsToDelete)= [];
    
    Seg_number = numel(locs)-1;
    Features = table();
    for i = 1:Seg_number
        
    Segment_start = locs(i)-50;
    Segment_end = locs(i+1)-50;
    PCG_segment =  Pfilt50signal(Segment_start:Segment_end);
     
% Features extraction.
        
        % Zero crossing rate
        Features.ZCR(i, 1)=mean(abs(diff(sign(PCG_segment))));
        
        % Mean value
        Features.MeanValue(i, 1) = mean(PCG_segment);
        
        % Median value
        Features.MedianValue(i, 1) = median(PCG_segment);
        
        % Highest value
        Features.HighestValue(i, 1) = max(abs(PCG_segment));
       
        % MeanFreq        
        Features.MeanFreq(i, 1) = meanfreq(PCG_segment);
        
        % Rootmeansquare
        Features.Rms(i, 1) = rms(PCG_segment);
        
        % Bandpower
        Features.Bandpower(i, 1) = bandpower(PCG_segment);
        
        % Median
        Features.Median(i, 1) = median(PCG_segment);

        % Standard deviation
        Features.StandardDeviation(i, 1) = std(PCG_segment);
        
        % Mean absolute deviation
        Features.MeanAbsoluteDeviation(i, 1) = mad(PCG_segment);
        
        % Quantile 25
        Features.Quantile25(i, 1) = quantile(PCG_segment, 0.25);
        
        % Quantile 75
        Features.Quantile75(i, 1) = quantile(PCG_segment, 0.75);
        
        % Inter quartile range(25-75).
        Features.IQR(i, 1) = iqr(PCG_segment);
        
        % Skewness
        Features.Skewness(i, 1) = skewness(PCG_segment);

        % Kurtosis
        Features.Kurtosis(i, 1) = kurtosis(PCG_segment);

        % Shannon's entropy 
        Features.signalEntropy(i, 1) = wentropy(PCG_segment,'shannon');

        % Spectral entropy
        Features.SpectralEntropy(i, 1) = pentropy(PCG_segment,fs);

        % Power spectrum features
        [maxfreq, maxval, maxratio] = FFT(PCG_segment, fs, 256);
        Features.FFTfreqmax(i, 1) = maxfreq;
        Features.FFTvalmax(i, 1) = maxval;
        Features.FFTRatio(i, 1) = maxratio;
        
        % Mel-frequency cepstral coefficients. 
        [MFCCs, ~, ~] = mfcc(PCG_segment,fs);
        Features.MFCC1(i, 1) = MFCCs(1);
        Features.MFCC2(i, 1) = MFCCs(2);
        Features.MFCC3(i, 1) = MFCCs(3);
        Features.MFCC4(i, 1) = MFCCs(4);
        Features.MFCC5(i, 1) = MFCCs(5);
        Features.MFCC6(i, 1) = MFCCs(6);
        Features.MFCC7(i, 1) = MFCCs(7);
        Features.MFCC8(i, 1) = MFCCs(8);
        Features.MFCC9(i, 1) = MFCCs(9);
        Features.MFCC10(i, 1) = MFCCs(10);
        Features.MFCC11(i, 1) = MFCCs(11);
        Features.MFCC12(i, 1) = MFCCs(12);
        Features.MFCC13(i, 1) = MFCCs(13);
        
        % Adding the labels column.
        if i == 1
            Features.class = {LabelMap(Label)};
        else
            Features.class{i, :} = LabelMap(Label);
        end
        
    end
    
    Features_Tabel = [Features_Tabel; Features];
end