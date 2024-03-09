clc;
load sampleEEGdata.mat;

eeg_data = EEG.data(32, :);

kernel_size = 3;

inverted_u = [1; 2; 1];
decay_kernel = [0.5; 1; 0.5];

padded_eeg_data = [zeros(1,kernel_size-1), eeg_data, zeros(1,kernel_size-1)];

conv_inverted_u = zeros(size(eeg_data));
for i = 1:length(eeg_data)
    conv_inverted_u(i) = sum(padded_eeg_data(i:i+kernel_size-1) .* inverted_u');
end

conv_decay = zeros(size(eeg_data));
for i = 1:length(eeg_data)
    conv_decay(i) = sum(padded_eeg_data(i:i+kernel_size-1) .* decay_kernel');
end

figure;

subplot(3,1,1);
stem(inverted_u, 'filled');
title('Inverted U Kernel');

subplot(3,1,2);
plot(eeg_data);
title(' EEG Data');

subplot(3,1,3);
plot(conv_inverted_u);
title('Convolution with Inverted U Kernel');

figure;

% Plot the Decay function kernel
subplot(3, 1, 1);
stem(decay_kernel, 'filled');
title('Decay Function Kernel');

% Plot the EEG data
subplot(3, 1, 2);
plot(eeg_data);
title('EEG Data');

% Plot the result of convolution with Decay function kernel
subplot(3, 1, 3);
plot(conv_decay);
title('Convolution with Decay Function Kernel');