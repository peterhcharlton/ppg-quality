# `PERFORM_TEMPLATE_CALC` - obtains a template photoplethysmogram (PPG) pulse wave.
##  Inputs
+   sig : a structure containing a PPG signal with fields:
    
     - v : a vector of PPG values
     - fs : the sampling frequency of the PPG in Hz
+   beat_inds : a vector containing indices of PPG beats
    
+   med_ibi : the median inter-beat interval (in samples)
    
+   do_distance_measures : a logical indicating whether or not to calculate the distance measures between each pulse wave and the template.
    
##  Outputs
+   templ : a vector containing a template pulse wave (at the original fs)
    
+   cc : mean correlation coefficient between individual pulse waves and the template
    
+   ed : Euclidean distance between individual pulse waves and the template
    
+   dis : Disimilarity between individual pulse waves and the template
    
##  Documentation
<https://ppg-quality.readthedocs.io/>

##  Author
Peter H. Charlton, University of Cambridge, 2024.

##  MIT License
       Copyright (c) 2024 Peter H. Charlton
       Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
       The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
       THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
