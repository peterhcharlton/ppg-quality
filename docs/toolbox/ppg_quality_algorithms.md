# PPG Quality Algorithms

Algorithms to assess the quality of photoplethysmogram (PPG) signals.

---

**Overview:** PPG-quality contains several algorithms to assess the quality of photoplethysmogram (PPG) signals. This page provides an overview of these algorithms. Follow the links for further details on each one.

**Accompanying tutorial:** See [this tutorial](./tutorials/ppg_quality_assessment) for an example of how to use the algorithms.

---

## Automatic Beat Detection

**Original publication:** 

Jang DG et al., A Simple and Robust Method for Determining the Quality of Cardiovascular Signals Using the Signal Similarity, _in Proc IEEE EMBC_, 2018, 478–481. DOI: [10.1109/EMBC.2018.8512341](https://doi.org/10.1109/EMBC.2018.8512341).

**Description:** The signal similarity is the correlation between the current pulse wave's shape and the previous pulse wave's shape. Before calculation, pulse waves are interpolated to a constant number of samples to account for handle pulse wave duration.

**Link:** [abd_beat_detector](../../functions/abd_beat_detector)

**Licence:** GNU GPL Licence

---

_**Source:** details of the peak detectors are taken fromTBC under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)._

---