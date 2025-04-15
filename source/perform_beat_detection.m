function beats = perform_beat_detection(sig, beat_detector)% PERFORM_BEAT_DETECTION  Detects beats in a PPG signal.
%   PERFORM_BEAT_DETECTION detects beats in a photoplethysmogram (PPG) signal
%   using a specified beat detection algorithm.
%   
%   # Inputs
%   
%   * sig : a structure containing a PPG signal with fields:
%    - v : a vector of PPG values
%    - fs : the sampling frequency of the PPG in Hz
%   * beat_detector : the abbreviation name of a beat detector (e.g. 'MSPTD')
%
%   # Pre-requisites
%   This function uses the 'ppg-beats' toolbox, which is available here: <https://ppg-beats.readthedocs.io/>
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

% detect beats
[beats.peaks, beats.onsets, beats.mid_amps] = detect_ppg_beats(sig, beat_detector);

end