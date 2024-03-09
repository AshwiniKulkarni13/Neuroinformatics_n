clc
load sampleEEGdata.mat

channel = 'fcz';

Xc = [EEG.chanlocs(:).X];
Yc = [EEG.chanlocs(:).Y];

[X, Y] = meshgrid(linspace(min(Xc), max(Xc), 100), linspace(min(Yc), max(Yc), 100));

chan_idx = find(strcmpi(channel, {EEG.chanlocs.labels}));
edata = squeeze(EEG.data(chan_idx, 1:50, 1));
Fs = EEG.srate;
freqs = 2:5:30;
bw = 6;

t = linspace(-2, 2, 2*Fs);
waveFam = zeros(length(freqs), length(t));

for i = 1:length(freqs)
    cf = freqs(i);
    s = bw / (2 * pi * cf);
    wavelet = exp(1i * 2 * pi * cf * t) .* exp(-t.^2 / (2 * s^2));
    waveFam(i, :) = abs(wavelet);
end

fEEGData = zeros(length(freqs), size(edata, 2));

for i = 1:length(freqs)
    convol_res = conv(edata, waveFam(i, :), 'same');
    convol_res = real(convol_res);
    fEEGData(i, :) = convol_res;
end

pp_matrix = zeros(size(fEEGData, 2), length(freqs), size(edata, 1), 2);

for i = 1:length(freqs)
    pp_matrix(:, i, :, 1) = abs(fEEGData(i, :)).^2;
    pp_matrix(:, i, :, 2) = angle(fEEGData(i, :));
end

time_pts = [180, 360];
time_pts = time_pts(time_pts <= size(pp_matrix, 1));

interp_pow = zeros(length(time_pts), length(freqs), size(X, 1), size(X, 2));
interp_ph = zeros(length(time_pts), length(freqs), size(X, 1), size(X, 2));

for ti = 1:length(time_pts)
    for fi = 1:length(freqs)
        interp_pow(ti, fi, :, :) = griddata(Xc, Yc, squeeze(pp_matrix(time_pts(ti), fi, :, 1)), X, Y);
        interp_ph(ti, fi, :, :) = griddata(Xc, Yc, squeeze(pp_matrix(time_pts(ti), fi, :, 2)), X, Y);
    end
end

for fi = 1:length(freqs)
    figure;
    sgtitle(['Frequency: ' num2str(freqs(fi)) 'Hz']);
    for ti = 1:length(time_pts)
        subplot(length(time_pts), 2, (ti-1)*2+1);
        topoplot(squeeze(interp_pow(ti, fi, :, :)), EEG.chanlocs, 'style', 'both', 'maplimits', [], 'electrodes', 'off');
        colorbar;
        title(['Power at ' num2str(time_pts(ti)) 'ms']);
        
        subplot(length(time_pts), 2, (ti-1)*2+2);
        topoplot(squeeze(interp_ph(ti, fi, :, :)), EEG.chanlocs, 'style', 'both', 'maplimits', [], 'electrodes', 'off');
        colorbar;
        title(['Phase at ' num2str(time_pts(ti)) 'ms']);
    end
end
