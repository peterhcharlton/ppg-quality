function [skewness, kurtosis, entropy] = calc_stats_metrics(sig)

% setup
x = sig.v;
N = length(x);
mu_x = mean(x);
omega = std(x);

% skewness
% - Based on eqn (3) in: M. Elgendi, Optimal signal quality index for photoplethysmogram signals3, Bioengineering, vol. 3, no. 4, pp. 1–15, 2016, doi: 10.3390/bioengineering3040021.
skewness = mean( ((x-mu_x)/omega).^3 );

% kurtosis
% - based on eqn (4) in: M. Elgendi, Optimal signal quality index for photoplethysmogram signals3, Bioengineering, vol. 3, no. 4, pp. 1–15, 2016, doi: 10.3390/bioengineering3040021.
kurtosis = mean( ((x-mu_x)/omega).^4 );

% entropy
% - based on eqn (2) in: [1] N. Selvaraj, Y. Mendelson, K. H. Shelley, D. G. Silverman, and K. H. Chon, ‘Statistical approach for the detection of motion/noise artifacts in Photoplethysmogram’, in Proc IEEE EMBS, IEEE, 2011, pp. 4972–4975. doi: 10.1109/IEMBS.2011.6091232.
% - inspired by: M. Elgendi, Optimal signal quality index for photoplethysmogram signals3, Bioengineering, vol. 3, no. 4, pp. 1–15, 2016, doi: 10.3390/bioengineering3040021.
no_bins = 16; % from Section II.C.2. in: [1] N. Selvaraj, Y. Mendelson, K. H. Shelley, D. G. Silverman, and K. H. Chon, ;Statistical approach for the detection of motion/noise artifacts in Photoplethysmogram’, in Proc IEEE EMBS, IEEE, 2011, pp. 4972–4975. doi: 10.1109/IEMBS.2011.6091232.
bin_lims = linspace(min(x),max(x),no_bins+1);
bin_p = zeros(no_bins,1);
for bin_no = 1 : no_bins
    bin_p(bin_no) = sum(x>=bin_lims(bin_no) & x<bin_lims(bin_no+1))/no_bins;
end
bin_p(end) = bin_p(end)+sum(x==bin_lims(end));
entropy = - sum( bin_p.*log(bin_p) ./ log(1/no_bins) );

end
