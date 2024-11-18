function sig_sim = calc_sig_sim(sig, beats)

% calculates signal similarity, based on the approach in D.-G. Jang et al., ‘A Simple and Robust Method for Determining the Quality of Cardiovascular Signals Using the Signal Similarity’, in 2018 40th Annual International Conference of the IEEE Engineering in Medicine and Biology Society (EMBC), Jul. 2018, pp. 478–481. doi: 10.1109/EMBC.2018.8512341.

no_samps = 50;
sig_sim = nan(length(beats.onsets),1);
for beat_no = 2 : length(beats.onsets)-1
    target_pw = sig.v(beats.onsets(beat_no):beats.onsets(beat_no+1));
    target_pw_resamp = interpolate_pw(target_pw, no_samps);
    adjacent_pw = sig.v(beats.onsets(beat_no-1):beats.onsets(beat_no));
    adjacent_pw_resamp = interpolate_pw(adjacent_pw, no_samps);
    temp = corrcoef(target_pw_resamp, adjacent_pw_resamp);
    cc = temp(1,2);
    sig_sim(beat_no) = cc;
end

end

function pw_resamp = interpolate_pw(pw, no_samps)
pw_resamp = interp1(1:length(pw), pw, linspace(1,length(pw),no_samps), "spline");
end