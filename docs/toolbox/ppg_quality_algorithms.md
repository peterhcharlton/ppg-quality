# PPG Quality Algorithms

Algorithms to assess the quality of photoplethysmogram (PPG) signals.

---

**Overview:** PPG-quality contains several algorithms to assess the quality of photoplethysmogram (PPG) signals. This page provides an overview of these algorithms. Follow the links for further details on each one.

**Accompanying tutorial:** See [this tutorial](./tutorials/ppg_quality_assessment) for an example of how to use the algorithms.

---

## Automatic Beat Detection

**Original publication:** Aboy M et al., An automatic beat detection algorithm for pressure signals. _IEEE Trans Biomed Eng_ 2005; 52: 1662-70. DOI: [10.1109/TBME.2005.855725](https://doi.org/10.1109/TBME.2005.855725)

**Description:** The PPG is strongly filtered to retain frequencies around an initial heart rate estimate, differentiated, and peaks are detected above the 75th percentile. Beats are identified as peaks in a weakly filtered PPG immediately following each peak identified in the differentiated signal.

**Link:** [abd_beat_detector](../../functions/abd_beat_detector)

**Licence:** GNU GPL Licence

---

_**Source:** details of the peak detectors are taken fromTBC under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)._

---