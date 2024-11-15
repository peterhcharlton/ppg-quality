function qual = assess_ppg_quality(ppg, fs, options)
% Calculates the following metrics of photoplethysmogram (PPG) signal
% quality:
% - Signal-to-noise ratio (SNR)
% - AC:DC ratio (and AC and DC amplitudes)
% - template-matching correlation coefficient
% - dynamic time warping template-matching
% - skewness
% - (needs updating)
%
% Inputs:
% - ppg: vector of PPG signal samples
% - fs: sampling frequency (Hz)
% - options: ...

%% Setup universal parameters
if nargin<3, options = struct; end
up = setup_up(fs, options);

%% Create signal structure
sig.v = ppg;
sig.fs = fs;

%%%%%%%%%% TO-DO %%%%%%%%%%%%%
% Need to implement a windowing step (currently it calculates a template for the whole window, and really this should be done on 10 sec windows or similar)
% NOTE: generally includes all the metrics which are applicable to non-absolute ppg signals from https://doi.org/10.3390/s22155831 https://doi.org/10.1109/TBME.2022.3158582 (except wavelet and HRV ones), and https://doi.org/10.3390/bioengineering3040021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SNR
qual.snr = calc_snr(sig, up);

%% Filter signal
sig_filtered = filter_sig(sig, up);

%% Detect beats (requied for some quality indices)
beats = detect_beats(sig_filtered, up);

%% find AC and DC components, and AC:DC ratio
[qual.ac_amp, qual.dc_amp, qual.ac_dc_ratio] = find_amp_ac_dc(up, sig, beats);

%% signal similarity
qual.sig_sim = find_sig_sim(sig_filtered.v, fs, beats, up);

%% template matching correlation coefficient
qual.tm_cc = find_tm_cc(sig, beats, up);

%% dynamic time warping euclidean distance and disimilarity measure
[qual.dtw_ed_on, qual.dtw_dis_on] = find_dtw_ed(sig, beats, up, 'onsets');
[qual.dtw_ed_pk, qual.dtw_dis_pk] = find_dtw_ed(sig, beats, up, 'peaks');

%% statistical measures
[qual.skewness, qual.kurtosis, qual.entropy] = find_statistical_metrics(sig, up);

%% pulse wave morphology measures
[qual.zcr, qual.firstderiv_zcr, qual.neg_neg_pk_jump, qual.pos_pos_pk_jump, qual.beat_amp_jump, qual.pulse_durn, qual.med_z_pulse, qual.npeaks_per_pw] = find_morphology_metrics(sig_filtered.v, sig_filtered.fs, beats, up);

%% frequency spectrum measures
[qual.rel_power] = find_spectrum_measures(sig.v, sig.fs, up);

end

function snr_val = calc_snr(sig, up)
filtered_sig.v = filtfilt(up.snr_bpf.b, up.snr_bpf.a, sig.v);
filtered_sig.fs = sig.fs;
snr_val = snr(filtered_sig.v);
end

function [ac_amp, dc_amp, ac_dc_ratio] = find_amp_ac_dc(up, sig, beats)

ac_amp = median(sig.v(beats.peaks)-sig.v(beats.onsets));
dc_amp = median((sig.v(beats.mid_amps)));
ac_dc_ratio = 100*ac_amp./abs(dc_amp);

end

function up = setup_up(fs, options)

% settings
if sum(strcmp(fieldnames(options), 'beat_detector'))
    up.beat_detector = options.beat_detector;
else
    up.beat_detector = 'MSPTD';
end

%% Design filters
% Design a high-pass Butterworth filter
up.hpf.order = 4; % Choose the filter order (adjust as needed)
cutoff_frequency = 0.5; % Cutoff frequency in Hz
[up.hpf.b, up.hpf.a] = butter(up.hpf.order, cutoff_frequency/(fs/2), 'high');
% Design a band-pass Butterworth filter
up.pk_detect_bpf.order = 4;
Nyquist = fs / 2; % Nyquist frequency
low_freq = 0.5; % Lower cutoff frequency in Hz
high_freq = 8; % Upper cutoff frequency in Hz
Wn = [low_freq, high_freq] / Nyquist; % Normalize the frequencies by the Nyquist frequency
[up.pk_detect_bpf.b, up.pk_detect_bpf.a] = butter(up.pk_detect_bpf.order, Wn, 'bandpass'); % Design the Butterworth bandpass filter
% Design a band-pass Chebyshev filter
up.snr_bpf.order = 4;
Nyquist = fs / 2; % Nyquist frequency
low_freq = 0.5; % Lower cutoff frequency in Hz
high_freq = 12; % Upper cutoff frequency in Hz
Wn = [low_freq, high_freq] / Nyquist; % Normalize the frequencies by the Nyquist frequency
[up.snr_bpf.b, up.snr_bpf.a] = cheby2(up.snr_bpf.order, 20, Wn); % Design the Chebyshev II bandpass filter
% Design a band-pass Butterworth filter (resp)
up.resp_bpf.order = 4;
Nyquist = fs / 2; % Nyquist frequency
low_freq = (4/60); % Lower cutoff frequency in Hz
high_freq = (45/60); % Upper cutoff frequency in Hz
Wn = [low_freq, high_freq] / Nyquist; % Normalize the frequencies by the Nyquist frequency
[up.resp_bpf.b, up.resp_bpf.a] = butter(up.resp_bpf.order, Wn, 'bandpass'); % Design the Butterworth bandpass filter

end

function sig_filtered = filter_sig(sig, up)

% filter signal
sig_filtered.v = filtfilt(up.pk_detect_bpf.b, up.pk_detect_bpf.a, sig.v);
sig_filtered.fs = sig.fs;

end

function beats = detect_beats(sig_filtered,up)

% detect beats
[beats.peaks, beats.onsets, beats.mid_amps] = detect_ppg_beats(sig_filtered, up.beat_detector);

end

function tm_cc = find_tm_cc(sig, beats, up)

% find median inter-beat-interval (in samples)
med_ibi = find_med_ibi(beats);

% calculate template (using mid-pts for alignment) and correlation coefficient
[templ, tm_cc, dtw_ed] = calculate_template(sig, beats, med_ibi, 'mid_amps');

end

function med_ibi = find_med_ibi(beats)

% use mid-pts
ibis = diff(beats.mid_amps);
med_ibi = median(ibis); % in samples

end

function [templ, cc, ed, dis] = calculate_template(sig, beats, med_ibi, fid_pt)

eval(['rel_beat_inds = beats.' fid_pt ';']);

tol = floor(med_ibi/2);
no_beats_used = 0;
all_waves = nan(length(rel_beat_inds),2*tol+1);
for beat_no = 1 : length(rel_beat_inds)

    % don't use this pulse wave if it's right at the beginning or end
    min_el = rel_beat_inds(beat_no)-tol;
    max_el = rel_beat_inds(beat_no)+tol;
    if min_el < 1 || max_el > rel_beat_inds(end)
        continue
    end

    % store this pulse wave in a matrix
    no_beats_used = no_beats_used + 1;
    all_waves(no_beats_used,:) = sig.v(min_el:max_el);
    
end

% remove any unused rows from matrix
all_waves(no_beats_used+1:end,:) = [];

% calculate template
templ = sum(all_waves,1)./no_beats_used;

% calculate correlation coefficient
ccs = nan(size(all_waves,1),1);
for beat_no = 1 : size(all_waves,1)
    
    % calculate CC between this pulse wave and the template
    curr_cc = corrcoef(all_waves(beat_no,:), templ);
    ccs(beat_no) = curr_cc(2);

end
cc = mean(ccs);

% normalise all waves
all_waves_norm = nan(size(all_waves));
for beat_no = 1 : size(all_waves,1)
    norm_pw = norm_0_1(all_waves(beat_no,:));
    all_waves_norm(beat_no,:) = norm_pw;
end

% normalise template
templ_norm = norm_0_1(templ);

% calculate euclidean distance
eds = nan(size(all_waves,1),1);
for beat_no = 1 : size(all_waves,1)
    
    % calculate euclidean distance between this pulse wave and the template
    [eds(beat_no), ix, iy] = dtw(all_waves_norm(beat_no,:),templ_norm);
    
    % calculate dissimilarity measure between this pulse wave and the template
    diss(beat_no) = calc_dis(all_waves_norm(beat_no,ix),templ_norm(iy));
end
ed = mean(eds);
dis = mean(diss);

end

function dis = calc_dis(pw, templ)

% following the methodology in https://doi.org/10.1016/j.imu.2019.100222 (Sec. 3.1.2.5)

% normalise to sum to one
pw = norm_sum_1(pw);
templ = norm_sum_1(templ);
rel_els = pw~=0 & templ~=0; % ignoring these because log(0) is -inf
dis = sum(templ(rel_els).*log(templ(rel_els)./pw(rel_els)));

end

function norm_pw = norm_sum_1(pw)

norm_pw = pw/(sum(pw));

end

function norm_pw = norm_0_1(pw)

norm_pw = (pw-min(pw))/range(pw);

end

function [dtw_ed, dtw_dis] = find_dtw_ed(sig, beats, up, fid_pt)

% find median inter-beat-interval (in samples)
med_ibi = find_med_ibi(beats);

% calculate template (using fid_pt for alignment) and correlation coefficient
[templ, tm_cc, dtw_ed, dtw_dis] = calculate_template(sig, beats, med_ibi, fid_pt);

end

function [skewness, kurtosis, entropy] = find_statistical_metrics(sig, up)

% setup
x = sig.v;
N = length(x);
mu_x = mean(x);
omega = std(x);

% skewness
% - Based on eqn (3) in: M. Elgendi, Optimal signal quality index for photoplethysmogram signals3, Bioengineering, vol. 3, no. 4, pp. 1–15, 2016, doi: 10.3390/bioengineering3040021.
skewness = mean( ((x-mu_x)/omega).^3 );

% kurtosis
% - based on eqn (4) in: M. Elgendi, Optimal signal quality index for photoplethysmogram signals3, Bioengineering, vol. 3, no. 4, pp. 1–15, 2016, doi: 10.3390/bioengineering3040021.
kurtosis = mean( ((x-mu_x)/omega).^4 );

% entropy
% - based on eqn (2) in: [1] N. Selvaraj, Y. Mendelson, K. H. Shelley, D. G. Silverman, and K. H. Chon, ‘Statistical approach for the detection of motion/noise artifacts in Photoplethysmogram’, in Proc IEEE EMBS, IEEE, 2011, pp. 4972–4975. doi: 10.1109/IEMBS.2011.6091232.
% - inspired by: M. Elgendi, Optimal signal quality index for photoplethysmogram signals3, Bioengineering, vol. 3, no. 4, pp. 1–15, 2016, doi: 10.3390/bioengineering3040021.
no_bins = 16; % from Section II.C.2. in: [1] N. Selvaraj, Y. Mendelson, K. H. Shelley, D. G. Silverman, and K. H. Chon, ;Statistical approach for the detection of motion/noise artifacts in Photoplethysmogram’, in Proc IEEE EMBS, IEEE, 2011, pp. 4972–4975. doi: 10.1109/IEMBS.2011.6091232.
bin_lims = linspace(min(x),max(x),no_bins+1);
bin_p = zeros(no_bins,1);
for bin_no = 1 : no_bins
    bin_p(bin_no) = sum(x>=bin_lims(bin_no) & x<bin_lims(bin_no+1))/no_bins;
end
bin_p(end) = bin_p(end)+sum(x==bin_lims(end));
entropy = - sum( bin_p.*log(bin_p) ./ log(1/no_bins) );

end

function [zcr, firstderiv_zcr, neg_neg_pk_jump, pos_pos_pk_jump, beat_amp_jump, pulse_durn, med_z_pulse, npeaks_per_pw] = find_morphology_metrics(filtered_sig, fs, beats, up)

% number of detected local maxima
% - from Table 2 of: S. Moscato, S. Lo Giudice, G. Massaro, and L. Chiari, :Wrist photoplethysmography signal quality assessment for reliable heart rate estimate and morphological analysis’, Sensors, vol. 22, no. 15, p. 5831, 2022, doi: 10.3390/s22155831.
% - perhaps slightly adapted to make it per pulse
rel_filtered_sig = filtered_sig(beats.onsets(1):beats.onsets(end));
no_local_max = sum(rel_filtered_sig(1:end-2)<rel_filtered_sig(2:end-1) & rel_filtered_sig(2:end-1)>rel_filtered_sig(3:end));  % doesn't account for a peak which spans multiple samples
npeaks_per_pw = no_local_max/(length(beats.onsets)-1);

% zero crossing rate
% - inspired by eqn (6) in: M. Elgendi, Optimal signal quality index for photoplethysmogram signals3, Bioengineering, vol. 3, no. 4, pp. 1–15, 2016, doi: 10.3390/bioengineering3040021.
% - the following code calculates what i think is the zero crossing rate, whereas I thought eqn (6) calculated the proportion of the signal which is less than zero 
durn = (length(filtered_sig)-1)/fs;  % -1 to calculate number of intervals, rather than number of samples
no_zc = sum( (filtered_sig(2:end)>0 & filtered_sig(1:end-1)<=0) | ...
    (filtered_sig(2:end)<=0 & filtered_sig(1:end-1)>0) );
zcr = no_zc/durn;

% first derivative zero crossing rate
% - from Table 2 of: S. Moscato, S. Lo Giudice, G. Massaro, and L. Chiari, :Wrist photoplethysmography signal quality assessment for reliable heart rate estimate and morphological analysis’, Sensors, vol. 22, no. 15, p. 5831, 2022, doi: 10.3390/s22155831.
% - not sure whether it's an exact implementation
% - haven't attempted to get a smooth first deriv, but using a filtered sig probably does this to some extent.
first_deriv = diff(filtered_sig);
durn = (length(first_deriv)-1)/fs;  % -1 to calculate number of intervals, rather than number of samples
no_zc = sum( (first_deriv(2:end)>0 & first_deriv(1:end-1)<=0) | ...
    (first_deriv(2:end)<=0 & first_deriv(1:end-1)>0) );
firstderiv_zcr = no_zc/durn;

% normalised negative-to-negative peak jump
% - from Section 3.1.2.2 in: E. Sabeti, N. Reamaroon, M. Mathis, J. Gryak, M. Sjoding, and K. Najarian, ‘Signal quality measure for pulsatile physiological signals using morphological features: Applications in reliability measure for pulse oximetry’, Informatics in Medicine Unlocked, vol. 16, p. 100222, Jan. 2019, doi: 10.1016/j.imu.2019.100222.
neg_peak_amps = filtered_sig(beats.onsets);
pos_peak_amps = filtered_sig(beats.peaks);
delta_Pneg_i = [nan; abs(diff(neg_peak_amps))];
delta_Pneg = nanmean(delta_Pneg_i);
P_i = abs(pos_peak_amps-neg_peak_amps);
delta_P_i = [nan; abs(diff(P_i))];
delta_P = nanmean(delta_P_i);
neg_neg_pk_jump = ( delta_Pneg_i - delta_Pneg ) ./ delta_P;

% normalised positive-to-positive peak jump
% - from Section 3.1.2.3 in: E. Sabeti, N. Reamaroon, M. Mathis, J. Gryak, M. Sjoding, and K. Najarian, ‘Signal quality measure for pulsatile physiological signals using morphological features: Applications in reliability measure for pulse oximetry’, Informatics in Medicine Unlocked, vol. 16, p. 100222, Jan. 2019, doi: 10.1016/j.imu.2019.100222.
delta_Ppos_i = [nan; abs(diff(pos_peak_amps))];
delta_Ppos = nanmean(delta_Ppos_i);
pos_pos_pk_jump = ( delta_Ppos_i - delta_Ppos ) ./ delta_P;

% normalised peak amplitude jump
% - from Section 3.1.2.4 in: E. Sabeti, N. Reamaroon, M. Mathis, J. Gryak, M. Sjoding, and K. Najarian, 4Signal quality measure for pulsatile physiological signals using morphological features: Applications in reliability measure for pulse oximetry’, Informatics in Medicine Unlocked, vol. 16, p. 100222, Jan. 2019, doi: 10.1016/j.imu.2019.100222.
beat_amp_jump = ( delta_P_i - delta_P ) ./ delta_P;

% normalised pulse duration
% - from Section 3.1.2.1 in: E. Sabeti, N. Reamaroon, M. Mathis, J. Gryak, M. Sjoding, and K. Najarian, 4Signal quality measure for pulsatile physiological signals using morphological features: Applications in reliability measure for pulse oximetry’, Informatics in Medicine Unlocked, vol. 16, p. 100222, Jan. 2019, doi: 10.1016/j.imu.2019.100222.
delta_p_i = [diff(beats.onsets);nan]./fs;
delta_p = nanmean(delta_p_i);
pulse_durn = (delta_p_i - delta_p ) ./ delta_p;

% median value of the z-scored PPG pulse
% - from Table 2 of: S. Moscato, S. Lo Giudice, G. Massaro, and L. Chiari, :Wrist photoplethysmography signal quality assessment for reliable heart rate estimate and morphological analysis’, Sensors, vol. 22, no. 15, p. 5831, 2022, doi: 10.3390/s22155831.
med_z_pulse = nan(length(beats.onsets),1);
for beat_no = 1 : length(beats.onsets)-1
    pw = filtered_sig(beats.onsets(beat_no):beats.onsets(beat_no+1));
    med_z_pulse(beat_no) = median((pw-mean(pw))./std(pw));
end

end

function [rel_power] = find_spectrum_measures(sig, fs, up)

ideal_downsample_freq = 30;
downsample_factor = floor(fs/ideal_downsample_freq);
downsample_freq = fs/downsample_factor;
segLen_min = 6*downsample_freq;
temp.v = decimate(sig, downsample_factor);
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

function sig_sim = find_sig_sim(sig, fs, beats, up)

% calculates signal similarity, based on the approach in D.-G. Jang et al., ‘A Simple and Robust Method for Determining the Quality of Cardiovascular Signals Using the Signal Similarity’, in 2018 40th Annual International Conference of the IEEE Engineering in Medicine and Biology Society (EMBC), Jul. 2018, pp. 478–481. doi: 10.1109/EMBC.2018.8512341.

no_samps = 50;
sig_sim = nan(length(beats.onsets),1);
for beat_no = 2 : length(beats.onsets)-1
    target_pw = sig(beats.onsets(beat_no):beats.onsets(beat_no+1));
    target_pw_resamp = interpolate_pw(target_pw, no_samps);
    adjacent_pw = sig(beats.onsets(beat_no-1):beats.onsets(beat_no));
    adjacent_pw_resamp = interpolate_pw(adjacent_pw, no_samps);
    temp = corrcoef(target_pw_resamp, adjacent_pw_resamp);
    cc = temp(1,2);
    sig_sim(beat_no) = cc;
end

end

function pw_resamp = interpolate_pw(pw, no_samps)
pw_resamp = interp1(1:length(pw), pw, linspace(1,length(pw),no_samps), "spline");
end

















