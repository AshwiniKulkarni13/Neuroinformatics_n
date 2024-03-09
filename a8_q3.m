clc
load sampleEEGdata.mat

channel = 'fcz';
Fs = 1000; 
frequencies = 2:5:30; 
bandwidth = 6; 
t = linspace(-2, 2, Fs); 
waveFam = zeros(length(frequencies), Fs); 

channel_index = find(strcmpi(channel, {EEG.chanlocs.labels}));
eeg_data = squeeze(EEG.data(channel_index, 1:50, 1));

for i = 1:length(frequencies)
    cf = frequencies(i); 
    s = bandwidth / (2 * pi * cf); 
    wavelet = exp(1i * 2 * pi * cf * t) .* exp(-t.^2 / (2 * s^2)); 
    waveFam(i, :) = abs(wavelet); 
end

filteredEEGData = zeros(length(frequencies), size(eeg_data, 2));

for i = 1:length(frequencies)
    convol_result = conv(eeg_data, waveFam(i, :), 'same');
    convol_result = real(convol_result);
    filteredEEGData(i, :) = convol_result;
end

averageConvEEGData = mean(filteredEEGData, 2);

figure;
for i = 1:length(frequencies)
    subplot(length(frequencies), 1, i);
    plot(averageConvEEGData(i, :));
    title(['ERP at ' num2str(frequencies(i)) 'Hz']);
    xlabel('Time (samples)');
    ylabel('Amplitude');
end

figure;
plot(mean(eeg_data, 1));
title('Broadband ERP (without convolution)');
xlabel('Time (samples)');
ylabel('Amplitude');

power_phase_matrix = zeros(size(filteredEEGData, 2), length(frequencies), size(eeg_data, 1), 2);

for i = 1:length(frequencies)
    power_phase_matrix(:, i, :, 1) = abs(filteredEEGData(i, :)).^2;
    power_phase_matrix(:, i, :, 2) = angle(filteredEEGData(i, :));
end

for electrode = 1:size(eeg_data, 1)
    figure;
    for i = 1:length(frequencies)
        subplot(2, length(frequencies), i);
        plot(power_phase_matrix(:, i, electrode, 1));
        title(['Power at ' num2str(frequencies(i)) 'Hz']);
        xlabel('Time (samples)');
        ylabel('Power');
        
        subplot(2, length(frequencies), length(frequencies) + i);
        plot(power_phase_matrix(:, i, electrode, 2));
        title(['Phase at ' num2str(frequencies(i)) 'Hz']);
        xlabel('Time (samples)');
        ylabel('Phase');
    end
end
