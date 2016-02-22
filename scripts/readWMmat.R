library(R.matlab)

## return a data.frame row of onset times
# onsets for: fix cue isi mem delay probe finish reponse
# etrl <-  m$trial['timing',,1]
onsetTimes <- function(etrl) {
 # onsets are the second list iteam in timing (first is ideal timing)
 # fix cue isi mem delay probe finish
 onsets <- sapply(etrl[1:7],'[[',2)
 # the names of events is in dimnames of the list
 names(onsets) <- attr(etrl,'dimnames')[[1]][1:7]
 # add resonpse
 d<-as.data.frame(t(onsets))

 d$response <- NA
 if( length(etrl) >7L) d$response <- etrl[[8]]

 return(d)
}

## read data from a mat file (two blocks)
# return dataframe with
#   playCue load changes block  RT Correct longdela# 
#   fix       cue       isi       mem    delay   probe   finish response 
readVisit <- function(mfile) {

   m<-readMat(mfile)
   ## get trial settings
   mdf <- m$events[c('playCue','load','changes','block','RT','Correct','longdelay'),,] %>% apply(1,unlist) %>% data.frame

   ## get times for each event in a trial
   tdf <- sapply(m$trial['timing',,],onsetTimes) %>% apply(1,unlist) %>% data.frame
   tdf <- tdf - m$starttime[mdf$block]
   tdf[ tdf < 0 ] <- -1

   # define catch type
   tdf$catchType <- NaN
   tdf$catchType[tdf$probe < 0 ] <- 'probe'
   tdf$catchType[tdf$delay < 0 ] <- 'delay'


   # merge the two
   trial <- cbind(mdf,tdf)

   return(trial)
}

# collapse trials into lines per blocks
linebyblock <- function(d,colname=1,nblocks=2) {
  cat(
    paste(
      collapse="\n",
      sapply(1:nblocks,
        function(b) {
          bd <- subset(d,block==b,select=-block)
          if(nrow(bd) > 0L)
            return(paste0(collapse=' ',sprintf('%0.2f',bd[,colname])))
          else
            return(sprintf('*'))
        }
      )
   )
 )
}


# write a 1D file given:
# - dataframe 
# - a column to use 
# - and a file name

save1D <- function(d,colname=1,fname="1.1D"){
 sink(fname)
 subset(visit,catchType=='delay') %>% linebyblock(colname) 
 cat("\n")
 sink()
}


# load a subjecs mat file
findSubjMat <- function(subjid) {
  # find mat file
  filepat <- sprintf('/Volumes/Phillips/P5/subj/%s/1d/WM/WorkingMemory_*.mat', subjid )
  matfile <- Sys.glob(filepat)[1]
  if(!file.exists(matfile)) error('cannot find file %s',filepat)
  return(matfile)

}

# write out cue (trial start) for catch types and correct types
writeCues <- function(subjid) {
  cwd<-getwd()
  # get mat file
  matfile <- findSubjMat(subjid)
  visit <- readVisit(matfile)

  # create output dir 
  setwd(dirname(matfile))
  if(! dir.exists('R1D')) dir.create('R1D')
  setwd('R1D')

  # write out each 1D file
  subset(visit,catchType=='delay')   %>% save1D('cue',"cue_allloads_delayCatch.1D") 
  subset(visit,catchType=='probe')   %>% save1D('cue',"cue_allloads_probeCatch.1D") 
  subset(visit,Correct==1)           %>% save1D('cue',"cue_allloads_correct.1D") 
  subset(visit,Correct %in% c(-1,0)) %>% save1D('cue',"cue_allloads_incorrect.1D") 

  cat('see list.files("', getwd(),'") and file.show(...)\n' )

  setwd(cwd)
}


# list all subjects
allSubjs <- function() {
 grep('1*_20*',dir('/Volumes/Phillips/P5/subj/'),value=T)
}

writeAll <-function(){
 apply(allSubjs(),writeCues)
}


## see also
#
# matfile <- '/Volumes/Phillips/P5/subj/10843_20151015/1d/WM/WorkingMemory_10843_fMRI_20151015.mat'
# visit <- readVisit(matfile)
# # same as
# visit <- readVisit(findSubjMat('10843_20151015'))
#
# head (visit)
#
# subset(visit,catchType=='delay') %>% linebyblock('cue') 
# subset(visit,catchType=='delay') %>% save1D('cue',"cue_delayCatch.1D") 


