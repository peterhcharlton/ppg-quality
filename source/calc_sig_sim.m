function sig_sim = calc_sig_sim(sig, beats)% CALC_SIG_SIM  Calculates signal similarity.
%   CALC_SIG_SIM calculates the signal similarity between consecutive pulse waves.
%   
%   # Inputs
%   
%   * sig : a structure containing the PPG signal with fields:
%    - v : a vector of signal values
%    - fs : the sampling frequency in Hz
%
%   * beats : a structure containing the indices of beat onsets:
%    - onsets : indices of onsets
%
%   # Outputs
%   
%   * sig_sim : the signal similarity for each pulse wave specified by the onset indices.
%
%   # Usage
%   The 'ppg-beats' toolbox can be used to obtain indices of detected beats: <https://ppg-beats.readthedocs.io/>
%
%   # Reference
%   D. G. Jang et al., 'A Simple and Robust Method for Determining the Quality of Cardiovascular Signals Using the Signal Similarity,' in Proc IEEE EMBC, 2018, 478–481. <https://doi.org/10.1109/EMBC.2018.8512341>
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