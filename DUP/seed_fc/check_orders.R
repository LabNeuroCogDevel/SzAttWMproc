### INIT
# should have run read_1d.R -- need variables from that file
needvals <- c('mask.file','mask_nii','vx_afni','m')
stopifnot(all(sapply(needvals,exists)))

double_check_index <- FALSE
check_voxel_order_of_raw <- FALSE

### AFNI INDEX ORDER
# use mask, enumerated indexes, and afni to get 
if(double_check_index) {
  enum_nii <- mask_nii
  datatype(enum_nii) <- 16
  bitpix(enum_nii) <- 32
  enum_nii@.Data[,,] <- 1:prod(dim(enum_nii@.Data))
  oro.nifti::writeNIfTI(enum_nii,'enum')
  afniidx <- system(sprintf("3dmaskave -q -udump -mask %s %s 2>/dev/null|sed /^+/d", mask.file, "enum.nii.gz"),intern=T)
  afni_order <- arrayInd(as.numeric(gsub(" ","",afniidx)), dim(enum_masked))
  stopifnot(afni_order == vx_afni)
}


##############
### check ordder
#############
if(check_voxel_order_of_raw){
  # find an example
  subj_no <- 1
  tp <- 1
  ex_vx <- 24
  rest <- "/Volumes/Phillips/P5/DUP/seed_fc/subjs/%s/brnswudktm_rest_5.nii.gz"
  subj <- names(allvalues)[subj_no]
  restsubj <- Sys.glob(sprintf(rest,subj))[1]

  # read in timeseries. very slow to read in!
  tsnii_ex <- oro.nifti::readNIfTI(restsubj)
  masked <- tsnii_ex@.Data[,,,tp] * mask_nii
  # sanitycheck: our mask has values where we told it to have valuse
  stopifnot(all(which(masked!=0, arr.ind=T) == vx_ijk) )

  ijk <- vx_afni[ex_vx,]
  val_ex <- tsnii_ex@.Data[ ijk[1] ,ijk[2],ijk[3], tp ]
  mavg_ex   <- m[tp,ex_vx,subj_no]
  stopifnot( abs(val_ex - mavg_ex ) < 10e-4)

  # all values for first timepoint
  maskave1d_vals <-  m[tp, , subj_no]

  # all vox vals # REALLY SLOW
  nvx <- dim(vx_afni)[1]
  vals<-rep(0,nvx)
  for (i in 1:nvx){
    v<-vx_afni[i,]
    vals[i] <-  tsnii_ex@.Data[v[1], v[2], v[3], 1]
  }
  print(cbind(maskave1d_vals[1:nvx],vals))
  stopifnot(max(abs(maskave1d_vals[1:nvx]-vals)) < 10e-4)
}
