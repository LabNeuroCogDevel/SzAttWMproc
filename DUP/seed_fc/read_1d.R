#!/usr/bin/env Rscript

# 20180501 -- voxel x voxel correlation of average (accross subject) ts
# -> probably not used. instead look at fsl's melodic for ICA
#

# function to read in file or return NULL
readfile <- function(f)  tryCatch( read.table(f), error=function(e) NULL)
# list all files
files <- Sys.glob("subjs/*/*_LGP_voxelwise_ts_noAvg.1d")
# read in all files (NULL if error)
allvalues <- lapply(files, FUN=readfile)
# assign name to each element of list
names(allvalues) <-  gsub(".*(\\d{5}_\\d{8}).*", "\\1", files)

# remove missing (LGP: 21: 11423_20140916)
allvalues <- allvalues[! sapply(allvalues, is.null) ]

# make into 3d matrix
# time x voxel x subject => 300 x 83 x 43 
m <- unlist(allvalues)
dim(m) <- c(dim(allvalues[[1]]), length(allvalues))
stopifnot( allvalues[[43]][24, 5] ==  m[24, 5, 43] )

# sum across all subjects: time x voxel => 300 x 83
mean_xsubj <- apply(m, MARGIN=c(1, 2), mean)
stopifnot( mean_xsubj[24, 5] == mean(m[24, 5, ]) )

# vox by vox correlation
cor_vox <- cor(mean_xsubj) # 83 x 83
stopifnot( cor_vox[24, 3] == cor(mean_xsubj[, 24], mean_xsubj[, 3]) )

# look at it
image(cor_vox)   # raw values
heatmap(cor_vox) # dendrogram

# ICA
ic_ts <- fastICA::fastICA(mean_xsubj, n.comp=5)
ic_cor <- fastICA::fastICA(cor_vox, n.comp=5)
