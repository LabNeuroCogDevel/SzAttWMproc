##output approximate slice times for MB data
##  to be used by preprocessFunctional via -custom_slice_times
# adapt from MH /Volumes/Serena/SPECC/MR_Raw/genMBSliceTimes.R

## Timing from dicom_hdr: 
# dicom_hdr -slice_times_verb  btc_08222014/ep2d_MB_attention_1_384x384.11/MR.1.3.12.2.1107.5.2.32.35217.2014082210010130270419696 2>&1| 
#  perl -slane 'next unless m/0{5}/; print map {sprintf "%.2f ", $_} @F;'
#
# 500.00 0.00 585.00 82.50 667.50 165.00 752.50 250.00 835.00 332.50 920.00 417.50

## R has same output as
# dicom_hdr -slice_.... | 
#  perl -slane 'next unless m/0{5}/; print join(",", map {(sprintf "%.2f", $_)/1000} (@F)x5);' > sliceTimings.1D


tr <- 1.0
nsimultaneous <- 5 #number of slices excited at once -- where is this in the dicom?
fromHeaderTimes <- c(500.00,0.00,585.00,82.50,667.50,165.00,752.50,250.00,835.00,332.50,920.00,417.50)/1000 #bottom to top in seconds
timing <- tcrossprod(fromHeaderTimes, rep(1, nsimultaneous)) #replicate timings vector 5x

sink("sliceTimings.1D")
cat(paste(as.vector(timing), collapse=","), "\n")
sink()

