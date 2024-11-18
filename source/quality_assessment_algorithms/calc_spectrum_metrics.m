function [rel_power] = calc_spectrum_metrics(sig)

ideal_downsample_freq = 30;
downsample_factor = floor(sig.fs/ideal_downsample_freq);
downsample_freq = sig.fs/downsample_factor;
segLen_min = 6*downsample_freq;
temp.v = decimate(sig.v, downsample_factor);
temp.v = detrend(temp.v); temp.v = temp.v(:);

% - Calculate Welch periodogram
segLen = 2^nextpow2(segLen_min);
noverlap = segLen/2;
[w_periodogram.power, w_periodogram.freqs] = pwelch(temp.v,segLen,noverlap, [], downsample_freq);
w_periodogram.power = w_periodogram.power./max(w_periodogram.power);

% - plot periodogram
do_plot = 0;
if do_plot
    ftsize = 16;
    plot(w_periodogram.freqs, w_periodogram.power, 'b', 'LineWidth', 2), hold on
    set(gca, 'YTick', [], 'FontSize', ftsize-4)
    xlabel('Frequency (Hz)', 'FontSize', ftsize)
    xlim([0 max(w_periodogram.freqs)])
    ylim([0 max(w_periodogram.power)*1.1])
    box off
end

% calculate rel power
% - from eqn (9) in: M. Elgendi, Optimal signal quality index for photoplethysmogram signals3, Bioengineering, vol. 3, no. 4, pp. 1–15, 2016, doi: 10.3390/bioengineering3040021.
rel_els_num = w_periodogram.freqs>= 1 & w_periodogram.freqs <= 2.25;
rel_els_den = w_periodogram.freqs>= 0 & w_periodogram.freqs <= 8;
rel_power = sum(w_periodogram.power(rel_els_num)) / sum(w_periodogram.power(rel_els_den));

end
