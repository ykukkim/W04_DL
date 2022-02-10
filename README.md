<!-- PROJECT LOGO -->
<br />
<div align="center">
  <h3 align="center">A deep-learning approach for automatically detecting gait-events based on foot-marker kinematics in children with cerebral palsy -- which markers work best for which gait patterns?</h3>
</div>


<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#how-to-use">How to Use</a></li>
      </ul>
    </li>
    <li><a href="#license">License</a></li>
  </ol>
</details>


<!-- ABOUT THE PROJECT -->
## About The Project

Normalisation of gait cycles is a key towards using clinical gait analysis as a tool to monitor neuromotor pathologies. Most commonly, this normalisation is achieved by detecting gait events, such as initial contact (IC) or toe-off (TO), through either manually annotated video data, or based on thresholds of ground reaction forces. This study developed a deep-learning long short-term memory approach to automatically detect IC and TO based on the foot-marker kinematics of $363$ Cerebral Palsy subjects (age: $11.8\pm{3.2}$). Different input combinations of four foot-markers (HLX, HEE, TOE, PMT5) were evaluated across three subgroups exhibiting different gait patterns (IC with the heel, midfoot, or forefoot). Overall, our approach detected 89.7\% of ICs within 16ms of the true event with a 18.5\% false alarm rate. For TOs, only 71.6\% of events were detected with a 33.8\% false alarm rate. While the TOE|HEE marker combination performed well across all subgroups for IC detection, optimal performance for TO detection required different input markers per subgroup with performance differences of 5-10\%. Thus, deep-learning based detection of IC events using the TOE|HEE marker offers an automated alternative to avoid operator-dependent and laborious manual annotation, as well as the limited step coverage and inability to measure assisted walking for force plate-based detection of IC events.


<!-- GETTING STARTED -->
## Getting Started

This git repository consists python codes for training the network. MATLAB was used for performance analysis.

### How to Use

1. Clone/download this repo
   ```sh
   git clone https://github.com/ykukkim/W04_DL.git
   ```
2. Trainin_LSTM -> consists python scripts from training to validating the performance of models.


### Requirement

Python version: 3.9
# CUDA 10.2
conda install pytorch==1.8.1 torchvision==0.9.1 torchaudio==0.8.1 cudatoolkit=10.2 -c pytorch
