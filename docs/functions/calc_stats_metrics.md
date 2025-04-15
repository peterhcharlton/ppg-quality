# `CALC_STATS_METRICS` - Calculates statistical metrics from a PPG signal segment.
##  Inputs
+   sig : a structure containing the PPG signal with fields:
    
     - v : a vector of signal values
     - fs : the sampling frequency in Hz
    
##  Outputs
+   skewness
    
+   kurtosis
    
+   entropy
    
##  Reference
M. Elgendi, Optimal signal quality index for photoplethysmogram
signals, Bioengineering, vol. 3, no. 4, pp. 1–15, 2016, <https://doi.org/10.3390/bioengineering3040021>
N. Selvaraj et al., ‘Statistical approach for the detection of motion/noise
artifacts in Photoplethysmogram’, in Proc IEEE EMBS, IEEE, 2011, pp.4972–4975. <https://doi.org10.1109/IEMBS.2011.6091232>

##  Documentation
<https://ppg-quality.readthedocs.io/>

##  Author
Peter H. Charlton, University of Cambridge, 2024.

##  MIT License
       Copyright (c) 2024 Peter H. Charlton
       Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
       The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
       THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
