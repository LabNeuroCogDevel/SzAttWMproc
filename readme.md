# Running
`make all` runs scripts in order. 

Scripts run for all data, but skip already completed tasks.

## Running portions
`Makefile` stores dependencies. so `make behave` will fetchData and then try to write 1d files. Where as `make glm` will fetchData, get 1d files, preprocess mprage (and send to copies for MEG people), preprocess functional, and run 3dDeconvolve.

# Scripts
 1. `00_fetchData.bash` -- get data from `wallace`
 1. `01_getBehave.bash` -- get data from `B` to create 1D files for GLM, write csv/\* for behav analysis, calls `getBehave_single.bash`
 1. `01_cpMprage.sh`    -- get (and preprocess) T1 Anat to place where MEG people can access it, calls `cpMprage_singleSubj.bash`
 1. `02_preproc.bash`   -- preprocess functional data, calls `preprocessOne.bash`
 1. `03_GLM.bash`       -- run GLM (3dDeconvolve) on preprocessed data. calls `deconvolve_only2*.bash` scripts

 * `01_cpDSI.bash`             -- copy raw DSI to `redrum` for collaboration
 * `getBehave_single.bash`     -- copies and creates 1d from behavioral data
 * `preprocessOne.bash`        -- preprocess T2s (also preprocess T1 if needed) 
 * `deconvolve_only2Att.bash`  -- model Att 
 * `deconvolve_only2WM.bash`   -- model WM 

## example
could call `make` OR

peicewise processing using `11333_20141017`
```bash
# get MR data
./00_fetchData.bash
# get Behave data: creates 1D files for afni, translates mat files into CSVs for behav inspection
./getBehave_single.bash 11333_20141017 Clinical

# waiting for MB reconstruction, can do mprage -- will be done by preprocessOne.bash if not done here
# copy MR T1 Anat image to open@reese so MEG people can use it
# edit https://docs.google.com/spreadsheets/d/1tklWovQor7Nt3m0oWsiP2RPRwDauIS8QUtY4la2kHac/edit
./cpMprage_singleSubj.bash 11333_20141017


# steve eventually has MB reconstructed
./00_fetchData.bash # to get the new MB data
./preprocessOne.bash  11333_20141017 attention_X1 attention_1
./preprocessOne.bash  11333_20141017 attention_X2 attention_2
./preprocessOne.bash  11333_20141017 workingMemory_X1 workingmemory_1
./preprocessOne.bash  11333_20141017 workingMemory_X2 workingmemory_2

./deconvolve_only2Att.bash 11333_20141017 
# can also give T2 preproc dir pattern as second argument 
./deconvolve_only2WM.bash 11333_20141017 workingmemory_[12]

```

