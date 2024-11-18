function beats = perform_beat_detection(sig, beat_detector)

% detect beats
[beats.peaks, beats.onsets, beats.mid_amps] = detect_ppg_beats(sig, beat_detector);

end