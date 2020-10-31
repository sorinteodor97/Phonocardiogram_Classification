function low_pass_filtered_signal = butterworth_low_pass_filter(signal,order,cutoff,sampling_frequency)

%Get the butterworth filter coefficients
[B_low,A_low] = butter(order,2*cutoff/sampling_frequency,'low');

% Designing the filter with the butterworth coefficients
low_pass_filtered_signal = filtfilt(B_low,A_low,signal);

end