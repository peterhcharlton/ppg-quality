function filtered_sig = perform_bpf(sig, bpf_coeffs)

filtered_sig.v = filtfilt(bpf_coeffs.b, bpf_coeffs.a, sig.v);
filtered_sig.fs = sig.fs;

end