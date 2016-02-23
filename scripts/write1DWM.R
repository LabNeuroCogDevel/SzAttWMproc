# get functions to read working memory mat files
source('readWMmat.R')



#####################
# function to write out 1D files (in curent working directory)
#
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
writeAll1DsWith(fulltrial20160223,outdir='R1D')
