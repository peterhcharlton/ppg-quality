function [templ, cc, ed, dis] = perform_template_calc(sig, beats, med_ibi, fid_pt, do_distance_measures)

eval(['rel_beat_inds = beats.' fid_pt ';']);

tol = floor(med_ibi/2);
no_beats_used = 0;
all_waves = nan(length(rel_beat_inds),2*tol+1);
for beat_no = 1 : length(rel_beat_inds)

    % don't use this pulse wave if it's right at the beginning or end
    min_el = rel_beat_inds(beat_no)-tol;
    max_el = rel_beat_inds(beat_no)+tol;
    if min_el < 1 || max_el > rel_beat_inds(end)
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


