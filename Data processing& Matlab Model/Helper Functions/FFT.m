function [maxfreq, maxval, maxratio] = FFT(data, fs, cutoff)

nfft = 4096;
f = fs/2*linspace(0,1,nfft/2);
cutoff = length(find(f <= cutoff));
f = f(1:cutoff);

% calculate the power spectrum using FFT method
datafft = fft(data,nfft);
ps = real(datafft.*conj(datafft));

% keep only the non-redundant portion
[~, nchannels] = size(data);
ps = ps(1:cutoff,:);
for i = 1:nchannels
    ps(:,i) = ps(:,i)/sum(ps(:,i));
end

% locate max value below cutoff
[maxval, maxind] = max(ps);
maxfreq = f(maxind);

% calculate peak energy by summing energy from maxfreq-delta to maxfreq+delta
% then normalize by total energy below cutoff
delta = 5;  % Hz
maxratio = zeros(1,nchannels);
for i = 1:nchannels
    maxrange = f>=maxfreq(i)-delta & f<=maxfreq(i)+delta;
    maxratio(i) = sum(ps(maxrange,i)) / sum(ps(:,i));
end