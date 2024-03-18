clc
% Load EEG data
load sampleEEGdata

% Select electrode
chan2use = 'fcz';

% Frequency of interest
freq_of_interest = 10; % For example, 10 Hz

% Parameters for multitaper method
NW = 2; % Time-half bandwidth product (typically between 1 and 3)
K = 2*NW - 1; % Number of tapers (typically 2*NW - 1)
window_length_sec = 1; % Window length in seconds
overlap_ratio = 0.5; % Overlap ratio
T = size(EEG.data, 2); % Total number of time points
N = 2^nextpow2(T); % Number of frequencies

% Calculate window length and overlap in samples
window_length_samples = round(window_length_sec * EEG.srate);
overlap_samples = round(window_length_samples * overlap_ratio);
step_size = window_length_samples - overlap_samples;

% Initialize arrays to store power spectral densities (PSDs)
psd_time = [];
psd_values = [];

% Iterate over EEG data in segments
for t = 1:step_size:T-window_length_samples+1
    % Extract segment of EEG data
    eeg_segment = squeeze(EEG.data(strcmpi(chan2use, {EEG.chanlocs.labels}), t:t+window_length_samples-1, :));
    
    % Compute PSD using multitaper method
    [pxx, f] = pmtm(eeg_segment, NW, N, EEG.srate);
    
    % Find index of frequency of interest
    [~, freq_idx] = min(abs(f - freq_of_interest));
    
    % Store time and corresponding PSD value
    psd_time(end+1) = EEG.times(t);
    psd_values(end+1) = pxx(freq_idx);
end

% Plotting
figure;
plot(psd_time, psd_values, 'b');
xlabel('Time (ms)');
ylabel('Power Spectral Density');
title(sprintf('Power over Time at %s electrode, %d Hz using Multitaper Method', chan2use, freq_of_interest));