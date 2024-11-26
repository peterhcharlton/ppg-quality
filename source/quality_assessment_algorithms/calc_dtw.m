function [dtw_ed_on, dtw_dis_on, dtw_ed_pk, dtw_dis_pk] = calc_dtw(sig, beats, med_ibi)% CALC_DTW  Calculates dynamic time warping metrics.
%   CALC_DTW calculates dynamic time warping metrics of PPG pulse waves.
%   
%   # Inputs
%   
%   * sig : a structure containing the PPG signal with fields:
%    - v : a vector of signal values
%    - fs : the sampling frequency in Hz
%
%   * beats : a structure containing the indices of beat peaks, onsets, and mid-amplitude points:
%    - peaks : indices of peaks
%    - onsets : indices of onsets
%    - mid_amps : indices of mid_amps
%
%   * med_ibi : the median inter-beat interval (in samples)
%
%   # Outputs
%   
%   * dtw_ed_on : dynamic time warping euclidean distance (obtained using onsets for alignment)
%   * dtw_dis_on : dynamic time warping disimilarity (obtained using onsets for alignment)
%   * dtw_ed_pk : dynamic time warping euclidean distance (obtained using peaks for alignment)
%   * dtw_dis_pk : dynamic time warping disimilarity (obtained using peaks for alignment)
%
%   # Usage
%   The 'ppg-beats' toolbox can be used to obtain indices of detected beats: <https://ppg-beats.readthedocs.io/>
%   The 'perform_med_ibi' function can be used to calculate a median inter-beat interval.
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


fid_pts = {'onsets', 'peaks'};

for fid_pt_no = 1 : length(fid_pts)

    % identify relevant fiducial point for template calculation
    curr_fid_pt = fid_pts{fid_pt_no};
    beat_inds = beats.(curr_fid_pt);  % selects the relevant field of the 'beats' structure

    % calculate template (using fid_pt for alignment) and correlation coefficient
    [templ, tm_cc, dtw_ed, dtw_dis] = perform_template_calc(sig, beat_inds, med_ibi, true);
    
    switch curr_fid_pt
        case 'onsets'
            dtw_ed_on = dtw_ed;
            dtw_dis_on = dtw_dis;
        case 'peaks'
            dtw_ed_pk = dtw_ed;
            dtw_dis_pk = dtw_dis;
    end

    clear templt tm_cc dtw_ed dtw_dis

end

end

