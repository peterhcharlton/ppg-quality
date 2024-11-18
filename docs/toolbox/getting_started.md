# Getting started with PPG-quality

A few pointers on how to quickly start using the toolbox.

---

## Downloading the toolbox

To download the toolbox, either (i) manually download it, or (ii) install it automatically in Matlab. _Please bear in mind the [Matlab requirements](#matlab-requirements) detailed below._

### (i) Manual download

The toolbox can be downloaded as a ZIP folder here:

<center>
<font size="+3">
<button type="button"> [Download Toolbox](https://github.com/peterhcharlton/ppg-quality/archive/refs/heads/main.zip) </button>
</font>
</center>

After downloading the toolbox:

1. Unzip the ZIP folder
2. Add the extracted files and folders to the Matlab path, using for instance `addpath(genpath('<path>'))`, where `<path>` is replaced with the path of the extracted files.

### (ii) Automatic Installation

Alternatively, the toolbox can be automatically downloaded and installed by:

1. Opening Matlab
2. Setting the current directory as the one where you want to save the toolbox, _e.g._
```cd C:/directoryname/```
3. Entering the following commands at the Matlab command window:

```
[old_path]=which('assess_ppg_quality'); if(~isempty(old_path)) rmpath(old_path(1:end-8)); end
toolbox_url='https://github.com/peterhcharlton/ppg-quality/archive/refs/heads/main.zip';
[filestr,status] = urlwrite(toolbox_url,'main.zip');
unzip('main.zip');
cd ppg-quality-main
addpath(genpath(pwd))
savepath
```
_NB: These instructions are adapted from those provided for the WFDB Toolbox [here](https://archive.physionet.org/physiotools/matlab/wfdb-app-matlab/)._

## Assessing the quality of PPG signals

The toolbox contains several PPG quality assessment algorithms, which are detailed [here](../../toolbox/ppg_quality_algorithms/).

These [PPG Beat Quality Assessment Tutorials](../../tutorials/ppg_quality_assessment/) provide instructions and code to quickly start assessing quality on sample data.

## Matlab Requirements

The toolbox is run in Matlab, and requires the following add-on:

- _TBC_

_NB: You can obtain details of which functions use which Matlab toolboxes by running a Dependency Report in Matlab._

## Finding the toolbox online

The toolbox is hosted by:

- [GitHub](https://github.com/peterhcharlton/ppg-quality/)
- [Mathworks File Exchange](#) (TBC)
- [Zenodo](#) (TBC)