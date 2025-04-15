# `CALC_SIG_SIM` - calculates the signal similarity between consecutive pulse waves.
##  Inputs
+   sig : a structure containing the PPG signal with fields:
    
     - v : a vector of signal values
     - fs : the sampling frequency in Hz
    
+   beats : a structure containing the indices of beat onsets:
    
     - onsets : indices of onsets
    
##  Outputs
+   sig_sim : the signal similarity for each pulse wave specified by the onset indices.
    
##  Usage
The 'ppg-beats' toolbox can be used to obtain indices of detected beats: <https://ppg-beats.readthedocs.io/>

##  Reference
D. G. Jang et al., 'A Simple and Robust Method for Determining the Quality of Cardiovascular Signals Using the Signal Similarity,' in Proc IEEE EMBC, 2018, 478–481. <https://doi.org/10.1109/EMBC.2018.8512341>

##  Documentation
<https://ppg-quality.readthedocs.io/>

##  Author
Peter H. Charlton, University of Cambridge, 2024.

##  MIT License
       Copyright (c) 2024 Peter H. Charlton
       Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
       The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
       THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
