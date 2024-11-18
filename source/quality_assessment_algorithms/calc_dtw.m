function [dtw_ed_on, dtw_dis_on, dtw_ed_pk, dtw_dis_pk] = calc_dtw(sig, beats, med_ibi)

fid_pts = {'onsets', 'peaks'};

for fid_pt_no = 1 : length(fid_pts)
    curr_fid_pt = fid_pts{fid_pt_no};

    % calculate template (using fid_pt for alignment) and correlation coefficient
    [templ, tm_cc, dtw_ed, dtw_dis] = perform_template_calc(sig, beats, med_ibi, curr_fid_pt, true);
    
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

