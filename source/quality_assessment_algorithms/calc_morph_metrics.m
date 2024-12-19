function [n_zc_per_pw, n_firstderiv_zc_per_pw, neg_neg_pk_jump, pos_pos_pk_jump, beat_amp_jump, pulse_durn, med_z_pulse, n_peaks_per_pw] = calc_morph_metrics(filtered_sig, beats)

% pre-processing
% - haven't attempted to get a smooth first deriv, but using a filtered sig probably does this to some extent.
first_deriv = diff(filtered_sig.v);
    
% cycling through each pulse wave
[n_peaks_per_pw, n_zc_per_pw, n_firstderiv_zc_per_pw] = deal(nan(length(beats.onsets),1));
for beat_no = 1 : length(beats.onsets)-1
    rel_filtered_sig.v = filtered_sig.v(beats.onsets(beat_no):beats.onsets(beat_no+1));
    rel_first_deriv = first_deriv(beats.onsets(beat_no):beats.onsets(beat_no+1));

    % number of detected local maxima
    % - from Table 2 of: S. Moscato, S. Lo Giudice, G. Massaro, and L. Chiari, :Wrist photoplethysmography signal quality assessment for reliable heart rate estimate and morphological analysis’, Sensors, vol. 22, no. 15, p. 5831, 2022, doi: 10.3390/s22155831.
    % - adapted to make it per pulse
    no_local_max = sum(rel_filtered_sig.v(1:end-2)<rel_filtered_sig.v(2:end-1) & rel_filtered_sig.v(2:end-1)>rel_filtered_sig.v(3:end));  % doesn't account for a peak which spans multiple samples
    n_peaks_per_pw(beat_no) = no_local_max;

    % zero crossing rate
    % - inspired by eqn (6) in: M. Elgendi, Optimal signal quality index for photoplethysmogram signals3, Bioengineering, vol. 3, no. 4, pp. 1–15, 2016, doi: 10.3390/bioengineering3040021.
    % - the following code calculates what i think is the zero crossing rate, whereas I thought eqn (6) calculated the proportion of the signal which is less than zero
    no_zc = sum( (rel_filtered_sig.v(2:end)>0 & rel_filtered_sig.v(1:end-1)<=0) | ...
        (rel_filtered_sig.v(2:end)<=0 & rel_filtered_sig.v(1:end-1)>0) );
    n_zc_per_pw(beat_no) = no_zc;

    % first derivative zero crossing rate
    % - from Table 2 of: S. Moscato, S. Lo Giudice, G. Massaro, and L. Chiari, :Wrist photoplethysmography signal quality assessment for reliable heart rate estimate and morphological analysis’, Sensors, vol. 22, no. 15, p. 5831, 2022, doi: 10.3390/s22155831.
    % - not sure whether it's an exact implementation
    no_zc = sum( (rel_first_deriv(2:end)>0 & rel_first_deriv(1:end-1)<=0) | ...
        (rel_first_deriv(2:end)<=0 & rel_first_deriv(1:end-1)>0) );
    n_firstderiv_zc_per_pw(beat_no) = no_zc;

end


% normalised negative-to-negative peak jump
% - from Section 3.1.2.2 in: E. Sabeti, N. Reamaroon, M. Mathis, J. Gryak, M. Sjoding, and K. Najarian, ‘Signal quality measure for pulsatile physiological signals using morphological features: Applications in reliability measure for pulse oximetry’, Informatics in Medicine Unlocked, vol. 16, p. 100222, Jan. 2019, doi: 10.1016/j.imu.2019.100222.
neg_peak_amps = filtered_sig.v(beats.onsets);
pos_peak_amps = filtered_sig.v(beats.peaks);
delta_Pneg_i = [nan; abs(diff(neg_peak_amps))];
delta_Pneg = mean(delta_Pneg_i,'omitnan');
P_i = abs(pos_peak_amps-neg_peak_amps);
delta_P_i = [nan; abs(diff(P_i))];
delta_P = mean(delta_P_i,'omitnan');
neg_neg_pk_jump = ( delta_Pneg_i - delta_Pneg ) ./ delta_P;

% normalised positive-to-positive peak jump
% - from Section 3.1.2.3 in: E. Sabeti, N. Reamaroon, M. Mathis, J. Gryak, M. Sjoding, and K. Najarian, ‘Signal quality measure for pulsatile physiological signals using morphological features: Applications in reliability measure for pulse oximetry’, Informatics in Medicine Unlocked, vol. 16, p. 100222, Jan. 2019, doi: 10.1016/j.imu.2019.100222.
delta_Ppos_i = [nan; abs(diff(pos_peak_amps))];
delta_Ppos = mean(delta_Ppos_i,'omitnan');
pos_pos_pk_jump = ( delta_Ppos_i - delta_Ppos ) ./ delta_P;

% normalised peak amplitude jump
% - from Section 3.1.2.4 in: E. Sabeti, N. Reamaroon, M. Mathis, J. Gryak, M. Sjoding, and K. Najarian, 4Signal quality measure for pulsatile physiological signals using morphological features: Applications in reliability measure for pulse oximetry’, Informatics in Medicine Unlocked, vol. 16, p. 100222, Jan. 2019, doi: 10.1016/j.imu.2019.100222.
beat_amp_jump = ( delta_P_i - delta_P ) ./ delta_P;

% normalised pulse duration
% - from Section 3.1.2.1 in: E. Sabeti, N. Reamaroon, M. Mathis, J. Gryak, M. Sjoding, and K. Najarian, 4Signal quality measure for pulsatile physiological signals using morphological features: Applications in reliability measure for pulse oximetry’, Informatics in Medicine Unlocked, vol. 16, p. 100222, Jan. 2019, doi: 10.1016/j.imu.2019.100222.
delta_p_i = [diff(beats.onsets);nan]./filtered_sig.fs;
delta_p = mean(delta_p_i,'omitnan');
pulse_durn = (delta_p_i - delta_p ) ./ delta_p;

% median value of the z-scored PPG pulse
% - from Table 2 of: S. Moscato, S. Lo Giudice, G. Massaro, and L. Chiari, :Wrist photoplethysmography signal quality assessment for reliable heart rate estimate and morphological analysis’, Sensors, vol. 22, no. 15, p. 5831, 2022, doi: 10.3390/s22155831.
med_z_pulse = nan(length(beats.onsets),1);
for beat_no = 1 : length(beats.onsets)-1
    pw = filtered_sig.v(beats.onsets(beat_no):beats.onsets(beat_no+1));
    med_z_pulse(beat_no) = median((pw-mean(pw))./std(pw));
end

end