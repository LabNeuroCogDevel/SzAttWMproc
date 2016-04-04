# get functions to read working memory mat files
source('readWMmat.R')



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


  # to test without writing to a file use null fname
  #
  #  subset(visit,Correct==1&load==1)  %>% save1D('cue',dur='tdur',fname=NULL) 
  #
  #   OR use the deeper function
  #  subset(visit,Correct==1&load==1) %>% linePerblock('cue',dur='tdur') 

}



# N.B. We are overwriting some of the matlab script
# MATLAB SCRIPT SHOULD BE RUN FIRST! 
# this does not provided catch + cue combined
# just partionals for incorrect cue, delay, and all of modulated probe
# OVERWERITES probe_ld*_correct
# in correct_load_wrongtogether_dlymod
ProbeRT20160225 <- function(visit) {

  # cue - wrong (same dur as cue correct)
  visit$cuedur <- visit$mem - visit$cue
  subset(visit,Correct %in% c(-1,0)) %>% save1D('cue',dur='cuedur',"cueonly_incorrect.1D") 

  # delay - wrong (same as dur delya correct)
  visit$dlydur <- visit$probe - visit$delay
  subset(visit,Correct %in% c(-1,0)) %>% save1D('delay',dur='dlydur',"dlyonly_incorrect.1D") 

  ## probe wrong (depend on RT, no resp)
  # probe
  visit$probedur <- ifelse(visit$response>0, 
                       visit$response - visit$probe,
                       visit$finish   - visit$probe)

  # correct
  subset(visit,Correct==1&load==1)   %>% save1D('probe',dur='probedur',"probe_ld1_correct.1D") 
  subset(visit,Correct==1&load %in% c(3,4) )   %>% save1D('probe',dur='probedur',"probe_ld3_correct.1D") 

  subset(visit,Correct %in% c(-1,0)) %>% save1D('probe',dur='probedur',"probe_incorrect.1D") 

}

# USAGE:
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
writeAll1DsWith(ProbeRT20160225,outdir='correct_load_wrongtogether_dlymod')
