#!/usr/bin/env Rscript


# 20180508 -- play with 3dmaskave roi dump and oronifti indexes
# Conclusion: oro read in LPI, afni index as RPI (even if input is LPI)
#             so need to sort x backwards

# read in a nifti file
example_file <- "/Volumes/Phillips/P5/DUP/seed_fc/GP_seeds_fromAtlas_FINAL/LGP.nii.gz"
example_nii <- oro.nifti::readNIfTI(example_file)
# system(sprintf("3dinfo -orient -space -n4 -ad3 -o3  %s",mask.file))
# LPI     MNI     84      100     84      1       2.300000        2.300000        2.300000        95.449997  131.850006       -77.449997

# make a new file enumerating every voxel
enum_nii <- example_nii
datatype(enum_nii) <- 16
bitpix(enum_nii) <- 32
enum_nii@.Data[,,] <- 1:prod(dim(enum_nii@.Data))
oro.nifti::writeNIfTI(enum_nii,'enum')

# make a single voxel mask
onevx_mask <- example_nii
onevx_mask@.Data[,,] <- 0
onevx_mask@.Data[c(48,49),c(56,57),c(30,31)] <- 1
oro.nifti::writeNIfTI(onevx_mask,'onevx_mask')

# get value at mask
enum_masked <- enum_nii@.Data[,,] * onevx_mask
vx_val <- which(enum_masked!=0)  
exp_val <- enum_masked[c(48,49),c(56,57),c(30,31)]  
dim(exp_val)<-c(1,prod(dim(exp_val)))
#  248268 248269 248352 248353 256668 256669 256752 256753
stopifnot( vx_val == exp_val ) 

# try with afni
afniidx <- system(sprintf("3dmaskave -q -udump -mask %s %s 2>/dev/null|sed /^+/d", "onevx_mask.nii.gz", "enum.nii.gz"),intern=T)
#  248269
#  248268
#  248353
#  248352
#  256669
#  256668
#  256753
#  256752
afni_order <- arrayInd(as.numeric(gsub(" ","",afniidx)), dim(enum_masked))
oro_order  <- arrayInd(exp_val, dim(enum_masked))
p <- cbind(oro_order,afni_order)
colnames(p) <- sapply(c('oro','nii'),paste,c('i','j','k'),sep='.')

# reorder oro to match afni
newvoxorder <- oro_order[order(oro_order[,3],oro_order[,2],-oro_order[,1]),]
stopifnot(all(newvoxorder == afni_order))


