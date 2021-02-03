Data loading and preparation matlab files
-----
copy_resting_state.m                - Copy resting state data to different folder
copy_the_present.m                  - Copy the present eeg data to different folder
copy_video.m                        - Copy all video files
check_tp_files_event.m              - Check event latency difference for the present movie
check_video_files.m                 - Check different types of movie files
cm_checkevents.m                    - Check events for other tasks
getjobid.m                          - Get SDSC job ID (does not work well or at all)
finputcheck.m                       - EEGLAB support function
loadtxt.m                           - EEGLAB support function

Deep learning Matlab files
-----
restingstate_prepare.m              - Prepare (segment) raw data (eyes open and closed)
restingstate_prepare_clean.m        - Prepare data clean (eyes open and closed)
restingstate_loaddata.m             - Load raw data (eyes open and closed)
restingstate_loaddata_clean.m       - Load raw data clean (eyes open and closed)
restingstate_prepare_spectrum.m     - Compute spectrum (run after restingstate_loaddata_clean)
restingstate_dl.m                   - Compute Deep learning on clean data
vgg16/dl_vgg16.m                    - Run VGG16 on spectral data

Data
---
vgg16/child_mind_spec.mat           - Child mind spectral data (output of restingstate_prepare_spectrum.m)
vgg16/vgg16.mat                     - Pretrained vgg16 (needed for SDSC)
GSN_HydroCel_129.sfp                - Electrode location file
HBN_all_Pheno.csv                   - Phenomenology

Folders
----
Readme_tasks                        - Readme files for some tasks (other in the 
MRI_align                           - Align MRI file with scanned channel files
paper                               - relevant papers
child-mind-TP                       - About 10 subject The Present data including eye tracking

SDSC job files
-----
job_child_mind_download.slurm       - Download child mind data
job_child_mind_unzip.slurm          - Unzip child mind data
job_resting_state_gpu6.slurm        - Run DL on child mind data

Results
-----
results.xlsx                        - LSTM deep learning results
