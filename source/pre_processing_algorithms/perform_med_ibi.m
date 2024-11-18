function med_ibi = perform_med_ibi(beats)

% use mid-pts
ibis = diff(beats.mid_amps);
med_ibi = median(ibis); % in samples

end