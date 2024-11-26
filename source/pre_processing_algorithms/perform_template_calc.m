function [templ, cc, ed, dis] = perform_template_calc(sig, beat_inds, med_ibi, do_distance_measures)% PERFORM_TEMPLATE_CALC  Obtains a template PPG pulse wave.
%   PERFORM_TEMPLATE_CALC obtains a template photoplethysmogram (PPG) pulse wave.
%   
%   # Inputs
%   
%   * sig : a structure containing a PPG signal with fields:
%    - v : a vector of PPG values
%    - fs : the sampling frequency of the PPG in Hz
%   * beat_inds : a vector containing indices of PPG beats
%   * med_ibi : the median inter-beat interval (in samples)
%   * do_distance_measures : a logical indicating whether or not to calculate the distance measures between each pulse wave and the template.
%
%   # Outputs
%
%   * templ : a vector containing a template pulse wave (at the original fs)
%   * cc : mean correlation coefficient between individual pulse waves and the template
%   * ed : Euclidean distance between individual pulse waves and the template
%   * dis : Disimilarity between individual pulse waves and the template
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


tol = floor(med_ibi/2);
no_beats_used = 0;
all_waves = nan(length(beat_inds),2*tol+1);
for beat_no = 1 : length(beat_inds)

    % don't use this pulse wave if it's right at the beginning or end
    min_el = beat_inds(beat_no)-tol;
    max_el = beat_inds(beat_no)+tol;
    if min_el < 1 || max_el > beat_inds(end)
        continue
    end

    % store this pulse wave in a matrix
    no_beats_used = no_beats_used + 1;
    all_waves(no_beats_used,:) = sig.v(min_el:max_el);
    
end

% remove any unused rows from matrix
all_waves(no_beats_used+1:end,:) = [];

% calculate template
templ = sum(all_waves,1)./no_beats_used;

% decide whether to calculate correlation coefficient
if do_distance_measures
    cc = nan;
else
    cc = calc_cc(all_waves, templ);
end

% decide whether to calculate distance measures
if do_distance_measures
    [ed, dis] = calc_dist_measures(all_waves, templ);
else
    ed = nan;
    dis = nan;
end

end

function [ed, dis] = calc_dist_measures(all_waves, templ)

% normalise all waves
all_waves_norm = nan(size(all_waves));
for beat_no = 1 : size(all_waves,1)
    norm_pw = norm_0_1(all_waves(beat_no,:));
    all_waves_norm(beat_no,:) = norm_pw;
end

% normalise template
templ_norm = norm_0_1(templ);

% calculate euclidean distance
eds = nan(size(all_waves,1),1);
for beat_no = 1 : size(all_waves,1)
    
    % calculate euclidean distance between this pulse wave and the template
    [eds(beat_no), ix, iy] = dtw(all_waves_norm(beat_no,:),templ_norm);
    
    % calculate dissimilarity measure between this pulse wave and the template
    diss(beat_no) = calc_dis(all_waves_norm(beat_no,ix),templ_norm(iy));
end
ed = mean(eds);
dis = mean(diss);

end

function dis = calc_dis(pw, templ)

% following the methodology in https://doi.org/10.1016/j.imu.2019.100222 (Sec. 3.1.2.5)

% normalise to sum to one
pw = norm_sum_1(pw);
templ = norm_sum_1(templ);
rel_els = pw~=0 & templ~=0; % ignoring these because log(0) is -inf
dis = sum(templ(rel_els).*log(templ(rel_els)./pw(rel_els)));

end

function norm_pw = norm_0_1(pw)

norm_pw = (pw-min(pw))/range(pw);

end

function norm_pw = norm_sum_1(pw)

norm_pw = pw/(sum(pw));

end

function cc = calc_cc(all_waves, templ)

% calculate correlation coefficient
ccs = nan(size(all_waves,1),1);
for beat_no = 1 : size(all_waves,1)

    % calculate CC between this pulse wave and the template
    curr_cc = corrcoef(all_waves(beat_no,:), templ);
    ccs(beat_no) = curr_cc(2);

end
cc = mean(ccs);

end


