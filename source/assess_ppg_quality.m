function [qual, onsets, win_start_els, win_end_els] = assess_ppg_quality(ppg, fs, options)
% ASSESS_PPG_QUALITY  Assess quality of a PPG signal.
%   ASSESS_PPG_QUALITY assesses the quality a photoplethysmogram (PPG) signal
%   using a specified quality assessment algorithm.
%   
%   # Inputs
%   
%   * ppg : a vector of PPG values
%   * fs : the sampling frequency of the PPG in Hz
%   * options : a stucture of options (as detailed below)
%
%   # Options
%
%   * beat_detector : a string specifying the beat detector algorithm to be used (default is MPSTDfast (v2))
%    
%   * quality_metrics  - a string specifying the quality assessment algorithm to be used, or a cell specifying multiple quality assessment algorithms. Options are:
%    - 'snr' : signal-to-noise ratio (after filtering the signal from 0.5-12 Hz)
%    - 'amp_metrics' : amplitude metrics (AC amplitude, DC amplitude, and AC:DC ratio)
%    - 'sig_sim' : signal similarity metric
%    - 'tm_cc' : template-matching correlation coefficient
%    - 'dtw' : dynamic time-warping template-matching
%    - 'stats_metrics' : statistical metrics
%    - 'morph_metrics' : pulse wave morphology metrics
%    - 'spectrum_metrics' : power spectrum metrics
%
%   * win_durn : the duration of the windows used to perform PPG signal quality assessment (in secs) (default is 10 secs)
%   
%   # Outputs
%   * qual : quality assessment results (in a structure)
%   * onsets : indices of pulse onsets
%   * win_start_els : indices of window starts
%   * win_end_els : indices of window ends
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

%%%%%%%%%% TO-DO %%%%%%%%%%%%%
% Need to implement a windowing step (currently it calculates a template for the whole window, and really this should be done on 10 sec windows or similar)
% Need to decide whether to output values for each beat or aggregate values
% NOTE: generally includes all the metrics which are applicable to non-absolute ppg signals from https://doi.org/10.3390/s22155831 https://doi.org/10.1109/TBME.2022.3158582 (except wavelet and HRV ones), and https://doi.org/10.3390/bioengineering3040021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Setup

% Setup universal parameters
if nargin<3, options = struct; end
up = setup_up(fs, options);

% Create signal structure
sig.v = ppg;
sig.fs = fs;

%% Pre-process

% perform each required preprocessing step (these can be conducted without windowing)
for step_no = 1 : length(up.preprocessing_steps_to_perform.all)
    curr_step = up.preprocessing_steps_to_perform.all{step_no};
    % perform this step
    switch curr_step
        case 'beat_detection'
            beats = perform_beat_detection(sig_beats_bpf, up.settings.beat_detector);
        case 'beats_bpf'
            sig_beats_bpf = perform_bpf(sig, up.pk_detect_bpf);
        case 'snr_bpf'
            sig_snr_bpf = perform_bpf(sig, up.snr_bpf);
    end
end
% % output 'onsets' when available
% if exist('beats', 'var')
%     onsets = beats.onsets;
% else
%     onsets = [];
% end

%% Window signal
[win_sep_els, ~] = find_win_sep_els(sig.v, sig.fs, beats, up);

% START HERE: need to adjust code below to use either of these win_sep_els
% depending on whether beats are required or not.

%% Calculate signal quality metrics

% - metrics which use windowing

% go through each window
last_win_beat_no = 0;
for win_no = 1 : length(win_sep_els.deb)

    % extract signals and beats of interest for this window
    curr_sig = extract_win_sig(sig.v, sig.fs, win_sep_els.deb(win_no), win_sep_els.fin(win_no));  % used for stats and spectrum metrics (which use generic windowing)
    curr_sig_snr_bpf = extract_win_sig(sig_snr_bpf.v, sig_snr_bpf.fs, win_sep_els.deb(win_no), win_sep_els.fin(win_no));  % used for SNR only (which uses generic windowing)
    [curr_beats, win_beat_nos] = extract_win_beats(beats, win_sep_els.deb(win_no), win_sep_els.fin(win_no));  % used for tm_cc or dtw
    
    % create wider signal for template-matching calculations which require signal either side of the window
    [curr_wider_sig, curr_wider_beats] = create_wider_signal(win_sep_els.deb(win_no), win_sep_els.fin(win_no), sig.v, sig.fs, curr_beats);  % used for tm_cc or dtw
    
    % keep only win beat nos which don't overlap with the previous window (this is only used for the last non-complete window)
    ref_beat_nos = win_beat_nos(win_beat_nos>last_win_beat_no);

    % calculate median IBI
    curr_med_ibi = perform_med_ibi(curr_beats.mid_amps);
    
    % go through each available quality metric
    for metric_no = 1 : length(up.settings.quality_metrics)
        curr_metric = up.settings.quality_metrics{metric_no};
        
        % calculate this metric
        switch curr_metric
                % snr
            case 'snr'
                curr_snr = calc_snr(curr_sig_snr_bpf);
                qual.snr(ref_beat_nos,1) = curr_snr;
                % statistical measures of quality
            case 'stats_metrics'
                [curr_skewness, curr_kurtosis, curr_entropy] = calc_stats_metrics(curr_sig);
                qual.skewness(ref_beat_nos,1) = curr_skewness;
                qual.kurtosis(ref_beat_nos,1) = curr_kurtosis;
                qual.entropy(ref_beat_nos,1) = curr_entropy;
                % spectral metrics
            case 'spectrum_metrics'
                curr_rel_power = calc_spectrum_metrics(curr_sig);
                qual.rel_power(ref_beat_nos,1) = curr_rel_power;
                % template matching correlation coefficient
            case 'tm_cc'
                curr_tm_cc = calc_tm_cc(curr_wider_sig, curr_wider_beats, curr_med_ibi);
                qual.tm_cc(ref_beat_nos,1) = curr_tm_cc(end-length(ref_beat_nos)+1:end);
                % dynamic time warping (currently window but should be pulse wave)
            case 'dtw'
                [curr_dtw_ed_on, curr_dtw_dis_on, curr_dtw_ed_pk, curr_dtw_dis_pk] = ...
                    calc_dtw(curr_wider_sig, curr_wider_beats, curr_med_ibi);
                qual.dtw_ed_on(ref_beat_nos,1) = curr_dtw_ed_on(end-length(ref_beat_nos)+1:end);
                qual.dtw_dis_on(ref_beat_nos,1) = curr_dtw_dis_on(end-length(ref_beat_nos)+1:end);
                qual.dtw_ed_pk(ref_beat_nos,1) = curr_dtw_ed_pk(end-length(ref_beat_nos)+1:end);
                qual.dtw_dis_pk(ref_beat_nos,1) = curr_dtw_dis_pk(end-length(ref_beat_nos)+1:end);
        end

    end

    last_win_beat_no = win_beat_nos(end);
end

% - metrics calculated for each pulse wave

% go through each available quality metric
for metric_no = 1 : length(up.settings.quality_metrics)
    curr_metric = up.settings.quality_metrics{metric_no};

    % calculate this metric
    switch curr_metric
            % amplitude metrics
        case 'amp_metrics'
            [qual.ac_amp, qual.dc_amp, qual.ac_dc_ratio] = calc_amp_metrics(sig, beats);
            % signal similarity
        case 'sig_sim'
            qual.sig_sim = calc_sig_sim(sig_beats_bpf, beats);
            % pulse wave morphology measures of quality
        case 'morph_metrics'
            [qual.n_zc_per_pw, qual.n_firstderiv_zc_per_pw, qual.neg_neg_pk_jump, qual.pos_pos_pk_jump, qual.beat_amp_jump, qual.pulse_durn, qual.med_z_pulse, qual.n_peaks_per_pw] = calc_morph_metrics(sig_snr_bpf, beats);
    end

end

win_start_els = win_sep_els.deb;
win_end_els = win_sep_els.fin;
onsets = beats.onsets;

end

function [curr_wider_sig, curr_wider_beats] = create_wider_signal(curr_start_el, curr_end_el, sig, fs, curr_wider_beats)

offset_beats_log = false;
if (curr_start_el-2*fs)>0
    curr_start_el = curr_start_el-2*fs;
    offset_beats_log = true;
end
if (curr_end_el+2*fs)<=length(sig)
    curr_end_el = curr_end_el+2*fs;
end
curr_wider_sig = extract_win_sig(sig, fs, curr_start_el, curr_end_el);

% offset the beats accordingly if the signal now starts earlier than previously
if offset_beats_log
    curr_wider_beats = offset_beats(curr_wider_beats, 2*fs);
end

end

function [win_sep_els, win_sep_els_beats] = find_win_sep_els(sig, fs, beats, up)

% find window duration in number of samples
win_durn_samps = round(up.settings.win_durn*fs)+1;

% find win start and finish els
win_sep_els.deb = 1:win_durn_samps:length(sig);
win_sep_els.fin = win_sep_els.deb + (win_durn_samps-1);

% find win start and finish els (constrained to pulse onsets)
win_sep_els_beats.deb = refine_to_nearest_pulse_onsets(win_sep_els.deb, beats);
win_sep_els_beats.fin = refine_to_nearest_pulse_onsets(win_sep_els.fin, beats);

% add in final window
if win_sep_els_beats.fin(end) < beats.peaks(end)
    win_sep_els_beats.fin(end+1) = beats.peaks(end);
    win_sep_els_beats.deb(end+1) = win_sep_els_beats.fin(end)-win_durn_samps;
    % refine to be at pulse onset
    [~, idx] = min(abs(beats.onsets-win_sep_els_beats.deb(end)));
    win_sep_els_beats.deb(end) = beats.onsets(idx);
end

end

function win_sep_els = refine_to_nearest_pulse_onsets(win_sep_els, beats)
% refined to separate at pulse onsets
for sep_el_no = 1 : length(win_sep_els)
    [~, idx] = min(abs(beats.onsets - win_sep_els(sep_el_no)));  % Find the closest onset
    win_sep_els(sep_el_no) = beats.onsets(idx);
end

end

function curr_sig = extract_win_sig(sig, fs, win_start_el, win_end_el)

curr_sig.fs = fs;

curr_sig.v = sig(win_start_el:win_end_el);

end

function curr_beats = offset_beats(curr_beats, offset)

fid_pts = fieldnames(curr_beats);
for fid_pt_no = 1 : length(fid_pts)
    curr_fid_pt = fid_pts{fid_pt_no};
    curr_beats.(curr_fid_pt) = curr_beats.(curr_fid_pt) + offset;
end

end

function [curr_beats, win_beat_nos] = extract_win_beats(beats, win_start_el, win_end_el)

% extract beats for this window
fid_pts = fieldnames(beats);
for fid_pt_no = 1 : length(fid_pts)
    curr_fid_pt = fid_pts{fid_pt_no};
    curr_fid_pt_beats = beats.(curr_fid_pt);
    if strcmp(curr_fid_pt, 'peaks')
        win_beat_nos = find(curr_fid_pt_beats>=win_start_el & curr_fid_pt_beats<=win_end_el);
    end
    curr_beats.(curr_fid_pt) = curr_fid_pt_beats(win_beat_nos);
    curr_beats.(curr_fid_pt) = curr_beats.(curr_fid_pt) - win_start_el + 1;
end

% tidy up - must start with an onset and end with a peak
if curr_beats.peaks(1) < curr_beats.onsets(1)
    curr_beats.peaks(1) = [];
    win_beat_nos(1) = [];
end
if curr_beats.onsets(end)> curr_beats.peaks(end)
    curr_beats.onsets(end) = [];
end
if curr_beats.mid_amps(1)<curr_beats.onsets(1)
    curr_beats.mid_amps(1) = [];
end
if curr_beats.mid_amps(end)>curr_beats.peaks(end)
    curr_beats.mid_amps(end) = [];
end

if ~isequal(length(curr_beats.onsets), length(curr_beats.peaks), length(curr_beats.mid_amps))
    error('check this')
end

end

function up = setup_up(fs, options)

%% Analysis settings

% specify settings (as optionally specified in the 'options' input)
option_vars = {'beat_detector', 'quality_metrics', 'win_durn'};
for option_var_no = 1 : length(option_vars)
    curr_option = option_vars{option_var_no};

    % - identify this option's setting
    if sum(strcmp(fieldnames(options), curr_option))
        % take provided setting for this option
        eval(['curr_option_val = options.' curr_option ';']);
    else
        % use default setting for this option
        switch curr_option
            % - beat detector
            case 'beat_detector'
                curr_option_val = 'MSPTDfastv2';
            % - quality assessment algorithm(s)
            case 'quality_metrics'
                curr_option_val = {'snr', 'amp_metrics', 'sig_sim', 'tm_cc', 'dtw', 'stats_metrics', 'morph_metrics', 'spectrum_metrics'};
            case 'win_durn'
                curr_option_val = 10;
        end
    end
    
    % - store this option's setting
    eval(['up.settings.' curr_option ' = curr_option_val;'])

end

% check that the quality metric(s) is a cell
if isstr(up.settings.quality_metrics)
    up.settings.quality_metrics = {up.settings.quality_metrics};
end

% identify required pre-processing steps
up.preprocessing_steps_to_perform.all = {};
for quality_metric_no = 1 : length(up.settings.quality_metrics)
    
    curr_quality_metric = up.settings.quality_metrics{quality_metric_no};

    % identify pre-processing step(s) for this quality_metric
    switch curr_quality_metric
        % - beat detector
        case 'amp_metrics'
            curr_pre_proc_steps = {'beats_bpf'; 'beat_detection'};
        case 'snr'
            curr_pre_proc_steps = {'snr_bpf'};
        case 'sig_sim'
            curr_pre_proc_steps = {'beats_bpf'; 'beat_detection'};
        case 'tm_cc'
            curr_pre_proc_steps = {'beat_detection'; 'med_ibi'};
        case 'dtw'
            curr_pre_proc_steps = {'beat_detection'; 'med_ibi'};
        case 'stats_metrics'
            curr_pre_proc_steps = {};
        case 'morph_metrics'
            curr_pre_proc_steps = {'snr_bpf'; 'beat_detection'};
        case 'spectrum_metrics'
            curr_pre_proc_steps = {};
    end

    % - store the preprocessing step(s) for this option
    eval(['up.preprocessing_steps_to_perform.' curr_quality_metric ' = curr_pre_proc_steps;'])
    up.preprocessing_steps_to_perform.all = [up.preprocessing_steps_to_perform.all; curr_pre_proc_steps];

end

% at the moment the code uses beats for everything, so need these steps:
if ~sum(contains(up.preprocessing_steps_to_perform.all, 'beat_detection'))
    up.preprocessing_steps_to_perform.all = ['beats_bpf'; 'beat_detection'; up.preprocessing_steps_to_perform.all];
end

% remove duplicate pre-processing steps
up.preprocessing_steps_to_perform.all = unique(up.preprocessing_steps_to_perform.all);

% re-order to move those steps that require other steps to the end
up.preprocessing_steps_to_perform.all = move_preprocess_step_to_end(up.preprocessing_steps_to_perform.all, 'beat_detection');
up.preprocessing_steps_to_perform.all = move_preprocess_step_to_end(up.preprocessing_steps_to_perform.all, 'med_ibi');

%% Design filters

% Design a high-pass Butterworth filter
if sum(strcmp(up.preprocessing_steps_to_perform.all, 'hpf'))
    up.hpf.order = 4; % Choose the filter order (adjust as needed)
    cutoff_frequency = 0.5; % Cutoff frequency in Hz
    [up.hpf.b, up.hpf.a] = butter(up.hpf.order, cutoff_frequency/(fs/2), 'high');
end

% Design a band-pass Butterworth filter
if sum(strcmp(up.preprocessing_steps_to_perform.all, 'beats_bpf'))
    up.pk_detect_bpf.order = 4;
    Nyquist = fs / 2; % Nyquist frequency
    low_freq = 0.5; % Lower cutoff frequency in Hz
    high_freq = 8; % Upper cutoff frequency in Hz
    Wn = [low_freq, high_freq] / Nyquist; % Normalize the frequencies by the Nyquist frequency
    [up.pk_detect_bpf.b, up.pk_detect_bpf.a] = butter(up.pk_detect_bpf.order, Wn, 'bandpass'); % Design the Butterworth bandpass filter
end

% Design a band-pass Chebyshev filter
if sum(strcmp(up.preprocessing_steps_to_perform.all, 'snr_bpf'))
    up.snr_bpf.order = 4;
    Nyquist = fs / 2; % Nyquist frequency
    low_freq = 0.5; % Lower cutoff frequency in Hz
    high_freq = 12; % Upper cutoff frequency in Hz
    Wn = [low_freq, high_freq] / Nyquist; % Normalize the frequencies by the Nyquist frequency
    [up.snr_bpf.b, up.snr_bpf.a] = cheby2(up.snr_bpf.order, 20, Wn); % Design the Chebyshev II bandpass filter
end

% Design a band-pass Butterworth filter (resp)
if sum(strcmp(up.preprocessing_steps_to_perform.all, 'resp_bpf'))
    up.resp_bpf.order = 4;
    Nyquist = fs / 2; % Nyquist frequency
    low_freq = (4/60); % Lower cutoff frequency in Hz
    high_freq = (45/60); % Upper cutoff frequency in Hz
    Wn = [low_freq, high_freq] / Nyquist; % Normalize the frequencies by the Nyquist frequency
    [up.resp_bpf.b, up.resp_bpf.a] = butter(up.resp_bpf.order, Wn, 'bandpass'); % Design the Butterworth bandpass filter
end

end

function preprocessing_steps = move_preprocess_step_to_end(preprocessing_steps, preprocessing_step_to_move)

rel_el = find(strcmp(preprocessing_steps, preprocessing_step_to_move));
if ~isempty(rel_el)
    preprocessing_steps(end+1) = preprocessing_steps(rel_el);
    preprocessing_steps(rel_el) = [];
end

end



