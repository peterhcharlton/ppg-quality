function [rel_power] = calc_spectrum_metrics(sig)% CALC_SPECTRUM_METRICS  Calculates power spectral density metrics.
%   CALC_SPECTRUM_METRICS  Calculates power spectral density metrics.
%   
%   # Inputs
%   
%   * sig : a structure containing the PPG signal with fields:
%    - v : a vector of signal values
%    - fs : the sampling frequency in Hz
%
%   # Outputs
%   
%   * rel_power : the ratio of the spectral power between 1 and 2.25 Hz, to that between 0 and 8 Hz.
%
%   # Reference
%   M. Elgendi, Optimal signal quality index for photoplethysmogram
%   signals, Bioengineering, vol. 3, no. 4, pp. 1–15, 2016, https://doi.org/10.3390/bioengineering3040021>
%   
%   # Documentation
%   <https://ppg-quality.readthedocs.io/>
%   
%   # Author
%   Peter H. Charlton, University of Cambridge, 2024.
%   
%   # MIT License
%      Copyright (c) 2024 Peter H. Charlton
%      Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
%      The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
%      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


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
% - from eqn (9) in: M. Elgendi, Optimal signal quality index for photoplethysmogram signals, Bioengineering, vol. 3, no. 4, pp. 1–15, 2016, doi: 10.3390/bioengineering3040021.
rel_els_num = w_periodogram.freqs>= 1 & w_periodogram.freqs <= 2.25;
rel_els_den = w_periodogram.freqs>= 0 & w_periodogram.freqs <= 8;
rel_power = sum(w_periodogram.power(rel_els_num)) / sum(w_periodogram.power(rel_els_den));

end
