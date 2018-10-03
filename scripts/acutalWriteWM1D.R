#!/usr/bin/env Rscript
setwd('/Volumes/Phillips/P5/scripts')
source('write1DWM.R')


# writeAll1DsWith(PPI_collapse_lds_20160829,outdir='PPI_collapse_lds')
# writeAll1DsWith(sepload_probeRT20160831,outdir='sepload_probeRT')

# or for just new (defined here) subjects

# TODO ADD NEW SUBJECTS
mysubjectlist <- commandArgs(T)
if(length(mysubjectlist)) error('give me lunaid_date as arguements')
for(subjid in mysubjectlist){
  # get visit info stored in matlab output files from task
  thismatfile <- findSubjMat(subjid)
  cat('reading in ',thismatfile,"\n")
  visit <- readVisit(thismatfile)
  
  # determine where to save output
  thissavedir <- sprintf('/Volumes/Phillips/P5/subj/%s/1d/WM/sepload_probeRT',subjid)
  if(!dir.exists(thissavedir)) dir.create(thissavedir) 
  setwd(thissavedir)
  
  # save out 1d files, show the directoyr
  sepload_probeRT20160831(visit)
  print(thissavedir)
  
  # again determin where to save 1d files and go there
  thissavedir <- sprintf('/Volumes/Phillips/P5/subj/%s/1d/WM/PPI_collapse_lds',subjid)
  if(!dir.exists(thissavedir)) dir.create(thissavedir) 
  setwd(thissavedir)
  
  # saveout 1ds
  PPI_collapse_lds_20160829(visit)
  print(thissavedir)
  
}

setwd('/Volumes/Phillips/P5/scripts')
