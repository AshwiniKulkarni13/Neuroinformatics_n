clc
% Load EEG data
load sampleEEGdata

% Select electrode
chan2use = 'fcz';

% Frequency of interest
freq_of_interest = 10; % For example, 10 Hz

% Define time window for short-time FFT
window_length = 200; % Example window length in milliseconds
overlap_ratio = 0.5; % Example overlap ratio
window_samples = round(window_length * EEG.srate / 1000); % Convert window length to samples
overlap_samples = round(window_samples * overlap_ratio); % Compute overlap in samples

% Compute the short-time FFT
chanidx = strcmpi(chan2use, {EEG.chanlocs.labels});
eeg_data_chan = squeeze(EEG.data(chanidx,:,:)); % Extract data for the selected channel
num_trials = size(eeg_data_chan, 2);
num_samples = size(eeg_data_chan, 1);
freq_resolution = EEG.srate / window_samples;
frequencies = 0:freq_resolution:EEG.srate/2;

% Initialize arrays to store power spectra
power_spectra = zeros(length(frequencies), num_samples, num_trials);

% Compute power spectra for each trial
for trial = 1:num_trials
    for t = 1:overlap_samples:num_samples-window_samples+1
        % Extract a segment of EEG data
        eeg_segment = eeg_data_chan(t:t+window_samples-1, trial);
        
        % Compute FFT of the segment
        fft_segment = fft(eeg_segment, window_samples);
        
        % Compute power spectrum (magnitude squared of FFT)
        power_spectrum = abs(fft_segment).^2;
        
        % Store power spectrum
        power_spectra(:, t, trial) = power_spectrum(1:length(frequencies));
    end
end

% Average power spectra across trials
mean_power_spectra = mean(power_spectra, 3);

% Plotting
time_axis = (0:num_samples-1) / EEG.srate * 1000; % Convert to milliseconds
figure;
imagesc(time_axis, frequencies, 10*log10(mean_power_spectra));
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
title(sprintf('Short-Time FFT Power Spectrogram at %s electrode', chan2use));
colorbar;
