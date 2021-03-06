library(R.matlab)
library(dplyr)
library(parallel)

# this file should be sourced from the script that will actually 
# define how to make the 1D files


###### USE THIS AS AN EXAMPLE
# write out cue (trial start) for catch types and correct types
# can be used as aggragate with 
#  writeAll1DsWith(writeCuesExample)
writeCuesExample <- function(visit) {
  # write out each 1D file
  subset(visit,catchType=='delay')   %>% save1D('cue',"cue_allloads_delayCatch.1D") 
  subset(visit,catchType=='probe')   %>% save1D('cue',"cue_allloads_probeCatch.1D") 
  subset(visit,Correct==1)           %>% save1D('cue',"cue_allloads_correct.1D") 
  subset(visit,Correct %in% c(-1,0)) %>% save1D('cue',"cue_allloads_incorrect.1D") 

}

## see also
#
# matfile <- '//10.145.64.109/Phillips/P5/subj/10843_20151015/1d/WM/WorkingMemory_10843_fMRI_20151015.mat'
# visit <- readVisit(matfile)
# # same as
# visit <- readVisit(findSubjMat('10843_20151015'))
#
# head (visit)
#
# subset(visit,catchType=='delay') %>% linePerblock('cue') 
# subset(visit,catchType=='delay') %>% save1D('cue',"cue_delayCatch.1D") 





############### HELPER FUNCTIONS

writeVisits1D <- function(subjid,writefunc=writeCuesExample,outdir='correct_load_wrongtogether_dlymod') {
  cat('#',subjid,'\n')
  # get mat file
  matfile <- findSubjMat(subjid)
  visit <- readVisit(matfile)

  # create output dir 
  cwd<-getwd()
  goto_mkdir(dirname(matfile), outdir)
  savedir<-getwd()

  # run function provided as input
  writefunc(visit)

  cat(sprintf('#see list.files("%s") and file.show("%s/...")\n', savedir,savedir ))

  setwd(cwd)
  return(savedir)
}

### run parallel on all subjects
#     ... is pasted to writeVisit1D
#     stand in for writefunc= and  outdir=
writeAll1DsWith <-function(...){
 lapply(allSubjs(),writeVisits1D,...)

 #mclapply(allSubjs(),writeVisits1D,writefunc,outdir)
}

# list all subjects
allSubjs <- function() {
 allsubjs <- grep('1*_20*',dir('//10.145.64.109/Phillips/P5/subj/'),value=T)
 # did not record isi onsets in 20140911
 allsubjs <- allsubjs[!allsubjs == '11327_20140911']

 # narrow to just those with matfiles
 # ..this means globbing is done twice .. oh well
 allmats <- unlist(lapply(allsubjs,findSubjMat))

 return(allsubjs[!is.na(allmats)])
}




## return a data.frame row of onset times
# onsets for: fix cue isi mem delay probe finish reponse
# etrl <-  m$trial['timing',,1]
onsetTimes <- function(etrl) {
 eventnames<-dimnames(etrl)[[1]]

 if(! 'isi' %in%  eventnames) {
    stop("No ISI event name!")
 }
 # onsets are the second list iteam in timing (first is ideal timing)
 # fix cue isi mem delay probe finish
 onsets <- sapply(etrl[1:7],'[[',2)
 # the names of events is in dimnames of the list
 names(onsets) <- eventnames[1:7]
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
   mdf <- m$events[c('playCue','load','changes','block','RT','Correct','longdelay'),,] %>% 
          apply(1,unlist) %>% 
          data.frame
   
   # error in orig mat files. corrected only in trial struct
   # so replace with this
   # -- otherwise we have 2's for all responses insatead of 0 or 1
   mdf$Correct <- unlist(m$trial['correct',,])
   
   ## get times for each event in a trial
   tdf <- sapply(m$trial['timing',,],onsetTimes) %>% apply(1,unlist) %>% data.frame
   tdf <- tdf - m$starttime[mdf$block]
   tdf[ tdf < 0 ] <- -1

   # define catch type
   tdf$catchType <- NaN
   tdf$catchType[tdf$probe < 0 ] <- 'probe'
   tdf$catchType[tdf$delay < 0 ] <- 'delay'


   # merge the two
   visit <- cbind(mdf,tdf)

   ## make finish better by accounting for catches

   # delay catch
   # mem dur was 20ms, add to mem onset if we skipped delay and after
   dlycatchidx<-visit$catchType=='delay'
   visit[dlycatchidx,'finish'] <- visit$mem[dlycatchidx] + .02

   # probe catch
   # saw either a 1 or 3 second duration delay
   # add to delay onset
   prbbatchidx<-visit$catchType=='probe'
   visit[prbbatchidx,'finish'] <- visit$delay[prbbatchidx] +
                                  ifelse(visit$longdelay[prbbatchidx]==1,1,3)

   return(visit)
}

# collapse trials into lines per blocks
linePerblock <- function(d,colname=1,nblocks=2,dur=NULL) {
  cat(
    paste(
      collapse="\n",
      sapply(1:nblocks,
        function(b) {
          bd <- subset(d,block==b,select=-block)
          if(nrow(bd) > 0L) {
            if(is.null(dur))
              return(paste0(collapse=' ',sprintf('%0.2f',bd[,colname])))
            else
              return(paste0(collapse=' ',sprintf('%0.2f:%0.2f',bd[,colname],bd[,dur])))
          } else {
            return(sprintf('*'))
          }
        }
      )
   )
 )
}


# write a 1D file given:
# - dataframe 
# - a column to use 
# - and a file name
# if fname is null, will not write to file

save1D <- function(d,colname=1,fname="1.1D",dur=NULL){
 if(!is.null(fname)) sink(fname)
 d %>% linePerblock(colname,dur=dur) 
 cat("\n")
 if(!is.null(fname)) sink()
}


# load a subjecs mat file
findSubjMat <- function(subjid) {
  # find mat file
  filepat <- sprintf('//10.145.64.109/Phillips/P5/subj/%s/1d/WM/WorkingMemory_*_fMRI_*.mat', subjid )
  matfile <- Sys.glob(filepat)
  if(length(matfile)!=1){ warning(sprintf('not exactly 1 %s',filepat)); return(NA)}
  matfile <- matfile[1]
  return(matfile)

}

# make and goto directory for writing 1D files
goto_mkdir <-function(rootdir,oneDdir) {
  setwd(rootdir)
  if(! dir.exists(oneDdir)) dir.create(oneDdir)
  setwd(oneDdir)
}



