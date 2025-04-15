function [skewness, kurtosis, entropy] = calc_stats_metrics(sig)% CALC_STATS_METRICS  Calculates statistical metrics.
%   CALC_STATS_METRICS  Calculates statistical metrics from a PPG signal segment.
%   
%   # Inputs
%   
%   * sig : a structure containing the PPG signal with fields:
%    - v : a vector of signal values
%    - fs : the sampling frequency in Hz
%
%   # Outputs
%   
%   * skewness
%   * kurtosis
%   * entropy
%
%   # Reference
%   M. Elgendi, Optimal signal quality index for photoplethysmogram
%   signals, Bioengineering, vol. 3, no. 4, pp. 1–15, 2016, <https://doi.org/10.3390/bioengineering3040021>
%   N. Selvaraj et al., ‘Statistical approach for the detection of motion/noise
%   artifacts in Photoplethysmogram’, in Proc IEEE EMBS, IEEE, 2011, pp.4972–4975. <https://doi.org10.1109/IEMBS.2011.6091232>
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


% setup
x = sig.v;
N = length(x);
mu_x = mean(x);
omega = std(x);

% skewness
% - Based on eqn (3) in: M. Elgendi, Optimal signal quality index for photoplethysmogram signals, Bioengineering, vol. 3, no. 4, pp. 1–15, 2016, doi: 10.3390/bioengineering3040021.
skewness = mean( ((x-mu_x)/omega).^3 );

% kurtosis
% - based on eqn (4) in: M. Elgendi, Optimal signal quality index for photoplethysmogram signals, Bioengineering, vol. 3, no. 4, pp. 1–15, 2016, doi: 10.3390/bioengineering3040021.
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
