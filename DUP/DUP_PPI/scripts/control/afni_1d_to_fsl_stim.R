#!/usr/bin/env Rscript

#
# convert all 1d files to fsl
#

source("/Volumes/Phillips/P5/DUP/DUP_PPI/scripts/AFNI1dtoFSL.R")
# look for all 1D files (sepload_probeRT, correct_load_wrongtogether, etc)
inputfiles <- Sys.glob("/Volumes/Phillips/P5/DUP/DUP_PPI/scripts/control/PPI/*/1d/*/*.1D")
l<-lapply(inputfiles, AFNI1dtoFSL)
# show which files we created
print(unname(unlist(l)))
