function high_pass_filtered_signal = butterworth_high_pass_filter(signal,order,cutoff,sampling_frequency)

%Get the butterworth filter coefficients
[B_high,A_high] = butter(order,2*cutoff/sampling_frequency,'high');

%Designing the filter with the butterworth coefficients
high_pass_filtered_signal = filtfilt(B_high,A_high,signal);

end

