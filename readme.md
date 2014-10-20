# Scripts
 1. `00_fetchData.bash` -- get data from `wallace`
 1. `01_getBehave.bash` -- get data from `B` to create 1D files for GLM, write csv/* for behav analysis
 1. `01_cpMprage.sh`    -- get (and preprocess) T1 Anat to place where MEG people can access it
 1. `preprocessOne.bash`  -- preprocess T2s (also preprocess T1 if needed) 
 1. `deconvolve_only2Att.bash`  -- model Att 
 1. `deconvolve_only2WM.bash`   -- model WM 

## example
using `11333_20141017`
```bash
# get MR data
./00_fetchData.bash
# get Behave data: creates 1D files for afni, translates mat files into CSVs for behav inspection
./01_getBehave.bash 11333_20141017 Clinical

# waiting for MB reconstruction, can do mprage -- will be done by preprocessOne.bash if not done here
# copy MR T1 Anat image to open@reese so MEG people can use it
# edit https://docs.google.com/spreadsheets/d/1tklWovQor7Nt3m0oWsiP2RPRwDauIS8QUtY4la2kHac/edit
./01_cpMprage.sh 11333_20141017

# steve eventually has MB reconstructed
./preprocessOne.bash  11333_20141017 attention_X1
./preprocessOne.bash  11333_20141017 attention_X2
./preprocessOne.bash  11333_20141017 workingMemory_X1
./preprocessOne.bash  11333_20141017 workingMemory_X2

./deconvolve_only2Att.bash 11333_20141017 
# can also give T2 preproc dir pattern as second argument (WM only)
./deconvolve_only2WM.bash 11333_20141017 workingMemory_X[12]


```
