function [ac_amp, dc_amp, ac_dc_ratio] = calc_amp_ac_dc(sig, beats)

ac_amp = median(sig.v(beats.peaks)-sig.v(beats.onsets));
dc_amp = median((sig.v(beats.mid_amps)));
ac_dc_ratio = 100*ac_amp./abs(dc_amp);

end