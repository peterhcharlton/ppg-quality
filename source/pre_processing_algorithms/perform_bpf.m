function filtered_sig = perform_bpf(sig, bpf_coeffs)% PERFORM_BPF  Band-pass filters a signal.
%   PERFORM_BPF band-pass filters a signal using a set of filter coefficients.
%   
%   # Inputs
%   
%   * sig : a structure containing the input signal with fields:
%    - v : a vector of signal values
%    - fs : the sampling frequency in Hz
%   
%   # Outputs
%   
%   * filtered_sig : a similar structure containing the filtered signal
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


filtered_sig.v = filtfilt(bpf_coeffs.b, bpf_coeffs.a, sig.v);
filtered_sig.fs = sig.fs;

end