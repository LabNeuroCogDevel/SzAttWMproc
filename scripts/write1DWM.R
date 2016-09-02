# get functions to read working memory mat files
setwd("/Volumes/Phillips/P5/scripts")
source('readWMmat.R')

# USAGE:
# AT END OF FILE (AFTER FUNCTIONS HAVE BEEN DEFINED)
#   #MANUAL:
#   # load data
#   visit <- readVisit(findSubjMat('11349_20141124'))
#   # go to 1D output directory
#   setwd('/Volumes/Phillips/P5/subj/11349_20141124/1d/WM/R1D')
#   # write to current directory
#   fulltrial20160223(visit)
#
#  # less manual: function to load the visit and cd to the output directory
#  writeVisits1D('11349_20141124',fulltrial20160223)
#
#  # can also use the outdir to change the final directory 
#  writeVisits1D('11349_20141124',fulltrial20160223,outdir='R1D')

#  # least manual:
#  # writeAll1DsWith will find all the subjects, load the visit, and write the files
#  writeAll1DsWith(fulltrial20160223,outdir='R1D')

############
# DO ALL
# first pass
#writeAll1DsWith(fulltrial20160223,outdir='R1D')
# overwrite probe correct from matlab
# add cue and delay incorrect


#####################
# function to write out 1D files (in curent working directory)
# if you want to make a new set of 1D files you need to make new
# pass to writeAll1DsWith , which will handle finding subjects, loading visit, and cd-ing)
# our run in subject 1D directory and load subjects visit yourself
#
#  EXAMPLE
#   visit <- readVisit(findSubjMat('11349_20141124'))
#   setwd('/Volumes/Phillips/P5/subj/11349_20141124/1d/WM/R1D')
#   fulltrial20160223(visit)
fulltrial20160223 <- function(visit) {

  # add duration 
  visit$tdur <- visit$finish - visit$cue


  # write out each 1D file
  subset(visit,catchType %in% c('delay','probe'))  %>% 
      save1D('cue',dur='tdur',"cue_catch.1D") 

  subset(visit,Correct==1&load==1)   %>% save1D('cue',dur='tdur',"cue_ld1_correct.1D") 
  subset(visit,Correct==1&load==3)   %>% save1D('cue',dur='tdur',"cue_ld3_correct.1D") 
  subset(visit,Correct %in% c(-1,0)) %>% save1D('cue',dur='tdur',"cue_incorrect.1D") 


  # to test use without filename defined
  #
  #  subset(visit,Correct==1&load==1)  %>% save1D('cue',dur='tdur') 
  #  #same as
  #  subset(visit,Correct==1&load==1) %>% save1D('cue',dur='tdur',fname=NULL) 
  #  # OR use the deeper function
  #  subset(visit,Correct==1&load==1) %>% linePerblock('cue',dur='tdur') 

}



# N.B. We are overwriting some of the matlab script
# MATLAB SCRIPT SHOULD BE RUN FIRST! 
# this does not provided catch + cue combined
# just partionals for incorrect cue, delay, and all of modulated probe
# OVERWERITES probe_ld*_correct
# in correct_load_wrongtogether_dlymod
#20160831-DONT USE THIS ONE IT WASNT CAPTURING THE CATCH FILES FOR CUE
ProbeRT20160225 <- function(visit) {


  # add columns: cuememdur, dlydur,probedur,and CorrectOrCatch
  # using readWMmat.R:setDurations
  visit <- setDurations(visit) 

  subset(visit,Correct %in% c(-1,0)) %>% save1D('cue'  ,dur='cuememdur',"cueonly_incorrect.1D") 
  subset(visit,Correct %in% c(-1,0)) %>% save1D('delay',dur='dlydur'   ,"dlyonly_incorrect.1D") 
  subset(visit,Correct %in% c(-1,0)) %>% save1D('probe',dur='probedur' ,"probe_incorrect.1D") 


  # correct
  subset(visit,Correct==1&ldtype=='low')  %>% save1D('cue',  dur='cuememdur',"cue_ld1_correct_test.1D") 
  subset(visit,Correct==1&ldtype=='high') %>% save1D('cue',  dur='cuememdur',"cue_ld3_correct_test.1D") 
  subset(visit,Correct==1&ldtype=='low')  %>% save1D('probe',dur='probedur' ,"probe_ld1_correct.1D") 
  subset(visit,Correct==1&ldtype=='high') %>% save1D('probe',dur='probedur' ,"probe_ld3_correct.1D") 

}

# ProbeRT20160225(readVisit(findSubjMat('11465_20160711')))
# 
# visit <- readVisit(findSubjMat('10843_20151015'))
# setwd('/Volumes/Phillips/P5/subj/10843_20151015/1d/WM/correct_load_wrongtogether_dlymod')
# ProbeRT20160225(visit)



#for PPI analyses, since there was no effect of load

PPI_collapse_lds_20160829 <- function(visit) {
  
  # add columns: cuememdur, dlydur,probedur,and CorrectOrCatch, ldtype
  # using readWMmat.R:setDurations
  visit <- setDurations(visit) 


  ## Incorrect
  subset(visit,Correct %in% c(-1,0)) %>% save1D('cue'  ,dur='cuememdur',"cueonly_incorrect.1D") 
  subset(visit,Correct %in% c(-1,0)) %>% save1D('delay',dur='dlydur'   ,"dlyonly_incorrect.1D") 
  subset(visit,Correct %in% c(-1,0)) %>% save1D('probe',dur='probedur' ,"probe_incorrect.1D") 
  
  ## correct
  subset(visit,CorrectOrCatch) %>% save1D('cue'  ,dur='cuememdur',"cue_correct.1D") 
  subset(visit,CorrectOrCatch) %>% save1D('delay',dur='dlydur'   ,"delay_correct.1D") 
  subset(visit,CorrectOrCatch) %>% save1D('probe',dur='probedur' ,"probe_correct.1D") 
  
}


# check just one 
visit <- readVisit(findSubjMat('10843_20151015'))
setwd('/Volumes/Phillips/P5/subj/10843_20151015/1d/WM/PPI_collapse_lds')
PPI_collapse_lds_20160829(visit)

# do all of them
writeAll1DsWith(PPI_collapse_lds_20160829,outdir='PPI_collapse_lds')



sepload_probeRT20160831 <- function(visit) {

  # add columns: cuememdur, dlydur,probedur,and CorrectOrCatch, ldtype
  # using readWMmat.R:setDurations
  visit <- setDurations(visit) 
  
  ## no response, incorrect
  subset(visit,Correct %in% c(-1,0)) %>% save1D('cue',  dur='cuememdur',"cueonly_incorrect.1D") 
  subset(visit,Correct %in% c(-1,0)) %>% save1D('delay',dur='dlydur'   ,"dlyonly_incorrect.1D") 
  subset(visit,Correct %in% c(-1,0)) %>% save1D('probe',dur='probedur' ,"probe_incorrect.1D") 
  
  
  ## correct by load

  # cue (cannot sep cue and mem, so dur is lenght of both)
  subset(visit,CorrectOrCatch&ldtype=='low' ) %>% save1D('cue'  ,dur='cuememdur',"cue_ld1_correct.1D") 
  subset(visit,CorrectOrCatch&ldtype=='high') %>% save1D('cue'  ,dur='cuememdur',"cue_ld3_correct.1D") 
  # delay
  subset(visit,CorrectOrCatch&ldtype=='low' ) %>% save1D('delay',dur='dlydur'   ,"delay_ld1_correct.1D") 
  subset(visit,CorrectOrCatch&ldtype=='high') %>% save1D('delay',dur='dlydur'   ,"delay_ld3_correct.1D") 
  # probe
  subset(visit,Correct==1    &ldtype=='low' ) %>% save1D('probe',dur='probedur' ,"probe_ld1_correct.1D") 
  subset(visit,Correct==1    &ldtype=='high') %>% save1D('probe',dur='probedur' ,"probe_ld3_correct.1D") 

  
}

# check one
visit <- readVisit(findSubjMat('10843_20151015'))
setwd('/Volumes/Phillips/P5/subj/10843_20151015/1d/WM/sepload_probeRT')
sepload_probeRT20160831(visit)

# write all
writeAll1DsWith(sepload_probeRT20160831,outdir='sepload_probeRT')


## LEGACY EXAMPLE; CONSIDERED HARMFUL (bad catch inclusion)
# writeAll1DsWith(ProbeRT20160225,outdir='correct_load_wrongtogether_dlymod')
# writeVisits1D('11559_20160719',ProbeRT20160225,outdir='correct_load_wrongtogether_dlymod')
# 
# # run just for 11333
# visit_load4 <- readVisit(findSubjMat('sm-20140829'))
# setwd('/Volumes/Phillips/P5/subj/sm-20140829/1d/WM/correct_load_wrongtogether_dlymod/')
# ProbeRT20160225(visit_load4)
