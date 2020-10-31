function Pfiltsignal = Pfilt50(signal,Fs)

% Creating the 50 HZ powerline interference filter.
d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',49,'HalfPowerFrequency2',51, ...
               'DesignMethod','butter','SampleRate',Fs);

Pfiltsignal=filtfilt(d,signal);
end

