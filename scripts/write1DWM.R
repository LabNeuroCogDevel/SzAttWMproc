# get functions to read working memory mat files
source('readWMmat.R')



fulltrial20160223 <- function(visit) {

  # add duration 
  visit$tdur <- visit$finish - visit$cue

  # to test without writing to a file use
  #   subset(visit,Correct==1&load==1) %>% linePerblock('cue',dur='tdur') 
  # or using null fname
  #  subset(visit,Correct==1&load==1)  %>% save1D('cue',dur='tdur',fname=NULL) 


  # write out each 1D file
  subset(visit,catchType %in% c('delay','probe'))  %>% 
      save1D('cue',dur='tdur',"cue_catch.1D") 

  subset(visit,Correct==1&load==1)   %>% save1D('cue',dur='tdur',"cue_ld1_correct.1D") 
  subset(visit,Correct==1&load==3)   %>% save1D('cue',dur='tdur',"cue_ld3_correct.1D") 
  subset(visit,Correct %in% c(-1,0)) %>% save1D('cue',dur='tdur',"cue_incorrect.1D") 

}

# test with:
#   # load data
#   visit <- readVisit(findSubjMat('11349_20141124'))
#
# write to current directory
#   fulltrial20160223(visit)
#
# output in correct directory
#  writeVisits1D('11349_20141124',fulltrial20160223)

# DO ALL
writeAll1DsWith(fulltrial20160223)
