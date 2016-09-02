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
# matfile <- '/Volumes/Phillips/P5/subj/10843_20151015/1d/WM/WorkingMemory_10843_fMRI_20151015.mat'
# visit <- readVisit(matfile)
# # same as
# visit <- readVisit(findSubjMat('10843_20151015'))
#
# head (visit)
#
# subset(visit,catchType=='delay') %>% linePerblock('cue') 
# subset(visit,catchType=='delay') %>% save1D('cue',"cue_delayCatch.1D") 





############### HELPER FUNCTIONS

writeVisits1D <- function(subjid,writefunc=writeCuesExample,outdir='R1D') {
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
 allsubjs <- grep('1*_20*',dir('/Volumes/Phillips/P5/subj/'),value=T)
 # did not record isi onsets in 20140911
 allsubjs <- allsubjs[!allsubjs == '11327_20140911']

 # narrow to just those with matfiles
 # ..this means globbing is done twice .. oh well
 allmats <- unlist(lapply(allsubjs,findSubjMat))

 return(allsubjs[!is.na(allmats)])
}




## return a data.frame row of onset times
# onsets for: fix cue isi mem delay probe finish reponse
# etrl <-  m$trial['timing',,1][[1]]
#
#   fix      List,2  
#   cue      List,2  
#   isi      List,2  
#   mem      List,2  
#   delay    List,2  
#   probe    List,2  
#   finish   List,2  
#   Response 279964.2

onsetTimes <- function(etrl) {
 eventnames<-dimnames(etrl)[[1]]

 if(! 'isi' %in%  eventnames) {
    stop("No ISI event name!")
    warning("No ISI event name! adding .2 to cue")
    # make isi from cue
    isi <- etrl[[2]]

    # add .2s from the cue onset to be the start of the isi
    # this is questionable
    isi[[2]] <- isi[[2]] + .2

    # add it in
    etrl <- append(etrl,isi,2)
    dimnames(etrl)[[1]] <- append(dimnames(etrl)[[1]],'isi',2)
 }
 # onsets are the second list item in timing (first is ideal timing)
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

# set durations
setDurations <- function(visit) {
  # make sure visit has all the columns we need
  needcols<-c('cue','mem','delay','probe','response','finish')
  if(!all(needcols %in% names(visit))) stop('setdurations: cannot find all needed columns in data frame',neecols)

  # duration of cue is when mem started minus when cue started
  # this includes isi
  # otherwise duration is .2
  # e.g.    
  #   round(visit$isi - visit$cue, 2) == .2
  # CUE DURATION CONSIDERED HARMFUL 20160902
  #   -- if used without mem, mem goes into baseline (which gives bad brain data)
  #      but there is no way to sep. cue from mem. so why use just cue (or just mem)
  #      COMMENTED out so will see errors if it's used
  #visit$cuedur <- visit$mem - visit$cue

  # want cue + mem b/c they cannot be separated 
  # add .2 directly (mem duration) instead of delay-cue b/c even if catch (delay=-1) we still have .2 before end of trial
  visit$cuememdur <- visit$cuedur + .2 

  # dly duration is onset of probe - start of delay
  visit$dlydur <- visit$probe - visit$delay

  # set load type to low or high
  # b/c we have mix of load 3 and load 4, both of which are high 
  visit$ldtype <- NA
  visit$ldtype[visit$load==1]          <- 'low'
  visit$ldtype[visit$load %in% c(3,4)] <- 'high'
  
  #probe wrong (depend on RT, no resp)
  visit$probedur <- ifelse(visit$response>0, 
                           visit$response - visit$probe,
                           visit$finish   - visit$probe )
  
  #BONUS column: correct or catch 
  # correct is NaN for catch trials. catchType is NaN for non-catch trials
  # we want correct or catch, either can be true
  visit$CorrectOrCatch <- visit$Correct==1 | is.nan(visit$Correct)

  # all catches do not have probe (==-1) and corrects should be NaN
  # warn if this is not the case
  if( all(is.nan(visit$Correct) == (visit$probe==-1)) != T ) warning('catch trials are funky, corrects==nan are not all probe==-1 ?!')


 return(visit)
}


# write a 1D file given:
# - dataframe 
# - a column to use 
# - and a file name
# if fname is null, will not write to file

save1D <- function(d,colname=1,fname=NULL,dur=NULL){

 ## check that we have the colname and durname in the datarfame passed
 if(!colname %in% names(d)) stop('cannot find ',colname, ' in dataframe')
 if(!is.null(dur) && ! dur %in% names(d)) stop('cannot find ', dur, ' in dataframe')

 ## remove NA and -1
 badidx <- is.na(d[,colname]) | d[,colname]<0                        # colname (onsettime)
 if(!is.null(dur)) { badidx <- badidx | is.na(d[,dur]) | d[,dur]<0 } # duration if specified
 d <- d[!badidx,]

 # where to write stimetimes (filename or stdout)
 if(!is.null(fname)) sink(fname)


 d %>% linePerblock(colname,dur=dur) 
 cat("\n")
 if(!is.null(fname)) sink()
}


# load a subjecs mat file
findSubjMat <- function(subjid) {
  # find mat file
  filepat <- sprintf('/Volumes/Phillips/P5/subj/%s/1d/WM/WorkingMemory_*_fMRI_*.mat', subjid )
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



