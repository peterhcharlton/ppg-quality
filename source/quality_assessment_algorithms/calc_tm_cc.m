function tm_ccs = calc_tm_cc(sig, beats, med_ibi)

% calculate template (using mid-pts for alignment) and correlation coefficient
[templ, tm_ccs, dtw_ed, dtw_dis] = perform_template_calc(sig, beats.mid_amps, med_ibi, true, false);

end
