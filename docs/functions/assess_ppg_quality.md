# `ASSESS_PPG_QUALITY` - Assesses quality of a PPG signal.
ASSESS_PPG_QUALITY assesses the quality a photoplethysmogram (PPG) signal
using a specified quality assessment algorithm.

##  Inputs
+   ppg : a vector of PPG values
    
+   fs : the sampling frequency of the PPG in Hz
    
+   quality_algorithm  - a string specifying the quality assessment 
    
algorithm to be used, or a cell specifying multiple quality assessment
algorithms

+   do_timing - a logical indicating whether or not to time how long it takes to run the beat detector algorithm
    
##  Outputs
+   onsets : indices of pulse onsets
    
+   qual : quality assessment results
    
+   t_taken : time taken (in secs) to run the beat detector algorithm
    
##  Documentation
<https://ppg-beats.readthedocs.io/>

##  Author
Peter H. Charlton, University of Cambridge, 2024.

##  MIT License
       Copyright (c) 2024 Peter H. Charlton
       Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
       The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
       THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
