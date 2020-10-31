function Pfilt60signal = Pfilt60(signal,Fs)

% Creating the 60 HZ powerline interference filter.
d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
               'DesignMethod','butter','SampleRate',Fs);

Pfilt60signal=filtfilt(d,signal);
end

