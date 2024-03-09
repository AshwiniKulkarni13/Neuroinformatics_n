clc
load sampleEEGdata.mat

channel = 'fcz';
Fs = 1000; 
freqs = 2:5:30; 
bw = 6; 
t = linspace(-2, 2, Fs); 
waveFam = zeros(length(freqs), Fs); 

chan_idx = find(strcmpi(channel, {EEG.chanlocs.labels}));
eeg_data = squeeze(EEG.data(chan_idx, 1:50, 1));

for i = 1:length(freqs)
    cf = freqs(i); 
    s = bw / (2 * pi * cf); 
    wavelet = exp(1i * 2 * pi * cf * t) .* exp(-t.^2 / (2 * s^2)); 
    waveFam(i, :) = abs(wavelet); 
end

filt_data = zeros(length(freqs), size(eeg_data, 2));

for i = 1:length(freqs)
    conv_res = conv(eeg_data, waveFam(i, :), 'same');
    conv_res = real(conv_res);
    filt_data(i, :) = conv_res;
end

figure;
imagesc(filt_data);
colormap('jet');
colorbar;
xlabel('Time (samples)');
ylabel('Frequency (Hz)');
title('Bandpass Filtered EEG Data at Peak Frequency of Morlet Wavelets');
