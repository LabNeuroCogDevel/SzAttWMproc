# get functions to read working memory mat files
#setwd("//10.145.64.109/Phillips/P5/scripts")
setwd("/Volumes/Phillips/P5/scripts")
source('readWMmat_PS.R')



#####################
# function to write out 1D files (in curent working directory)
# if you want to make a new set of 1D files you need to make new
# pass to writeAll1DsWith , which will handle finding subjects, loading visit, and cd-ing)
# our run in subject 1D directory and load subjects visit yourself
#
#  EXAMPLE: *******USE FOR SUBJ 11333************* need to chande load==3 to load==4
visit <- readVisit(findSubjMat('11228_20150309'))   
#visit <- readVisit(findSubjMat('11228_20150309'))
   #setwd('//10.145.64.109/Phillips/P5/subj/11333_20141017/1d/WM/R1D_SPMG3_nomarry')
   #fulltrial20160223(visit)
fulltrial20160223 <- function(visit) {

  # add duration 
  visit$tdur <- visit$finish - visit$cue
  
  visit$tdurdelay<-ifelse(visit$probe==-1,visit$finish-visit$delay,visit$probe-visit$delay)
  
  visit$tdurresp <- visit$finish -visit$probe

  # write out each 1D file
  #subset(visit,Correct==1&load==3)   %>% save1D('cue',dur='tdur',"cue_ld3_correct.1D") 
  #subset(visit,Correct %in% c(-1,0)) %>% save1D('cue',dur='tdur',"cue_incorrect.1D")
  #subset(visit,catchType %in% c('delay','probe'))  %>% save1D('cue',dur='tdur',"cue_catch.1D")
  
  #took out dur = "tdur" because using for TENT, save to dir R1D_nomarry
  #subset(visit,catchType=="probe"&longdelay==0)   %>% save1D('cue',"cue_catchProbe_delay1.1D")
  #subset(visit,catchType=="probe"&longdelay==1)   %>% save1D('cue',"cue_catchProbe_delay3.1D")
  #subset(visit,catchType=="delay")   %>% save1D('cue',"cue_catchDelay.1D")
  subset(visit,Correct==1&load==1&playCue==1| catchType =="delay"&load==1&playCue==1)   %>% save1D('cue',"cue_ld1_left.1D")
  subset(visit,Correct==1&load==1&playCue==2| catchType =="delay"&load==1&playCue==2)   %>% save1D('cue',"test_right.1D")
  subset(visit,Correct==1&load==1 | catchType =="delay"&load==1)   %>% save1D('cue',"cue_ld1_incCatch_Correct.1D")
  subset(visit,Correct==1&load==3 | catchType =="delay"&load==3)   %>% save1D('cue',"cue_ld3_incCatch_Correct.1D")
  subset(visit,Correct==1&load==1&longdelay==0|catchType =="probe"&load==1&longdelay==0)   %>% save1D('delay',"delay_ld1_dly1_incCatch_Correct.1D")
  subset(visit,Correct==1&load==1&longdelay==1|catchType =="probe"&load==1&longdelay==1)   %>% save1D('delay',"delay_ld1_dly3_incCatch_Correct.1D")
  subset(visit,Correct==1&load==3&longdelay==0|catchType =="probe"&load==3&longdelay==0)   %>% save1D('delay',"delay_ld3_dly1_incCatch_Correct.1D")
  subset(visit,Correct==1&load==3&longdelay==1|catchType =="probe"&load==3&longdelay==1)   %>% save1D('delay',"delay_ld3_dly3_incCatch_Correct.1D")
  subset(visit,Correct==1&load==1)   %>% save1D('probe',"probe_ld1_Correct.1D")
  subset(visit,Correct==1&load==3)   %>% save1D('probe',"probe_ld3_Correct.1D")
  subset(visit,Correct %in% c(-1,0))   %>% save1D('cue',"cue_wrong.1D")
  subset(visit,Correct %in% c(-1,0))   %>% save1D('probe',"probe_wrong.1D")
  subset(visit,Correct %in% c(-1,0)&longdelay==0)   %>% save1D('delay',"delay_dly1_wrong.1D")
  subset(visit,Correct %in% c(-1,0)&longdelay==1)   %>% save1D('delay',"delay_dly3_wrong.1D")
  #subset(visit,Correct %in% c(-1,0)&longdelay==1)   %>% save1D('cue',"cue_incorrect_delay3.1D")
  # to test without writing to a file use null fname
  #
  #  subset(visit,Correct==1&load==1)  %>% save1D('cue',dur='tdur',fname=NULL) 
  #
  #   OR use the deeper function
  #  subset(visit,Correct==1&load==1) %>% linePerblock('cue',dur='tdur') 

}
lateral_timing <- function(visit) {
  visit$tdur <- visit$finish - visit$cue
  
  visit$tdurdelay<-ifelse(visit$probe==-1,visit$finish-visit$delay,visit$probe-visit$delay)
  
  visit$tdurresp <- visit$finish -visit$probe
subset(visit,Correct==1&load==1&playCue==1| catchType =="delay"&load==1&playCue==1)   %>% save1D('cue',dur="tdur","cue_ld1_catchInc_L.1D")
subset(visit,Correct==1&load==1&playCue==2| catchType =="delay"&load==1&playCue==2)   %>% save1D('cue',dur="tdur","cue_ld1_catchInc_R.1D")
subset(visit,Correct==1&load==3&playCue==1| catchType =="delay"&load==3&playCue==1)   %>% save1D('cue',dur="tdur","cue_ld3_catchInc_L.1D")
subset(visit,Correct==1&load==3&playCue==2| catchType =="delay"&load==3&playCue==2)   %>% save1D('cue',dur="tdur","cue_ld3_catchInc_R.1D")

subset(visit,Correct==1&load==1&playCue==1| catchType =="probe"&load==1&playCue==1)   %>% save1D('delay',dur="tdurdelay","delay_ld1_catchInc_L.1D")
subset(visit,Correct==1&load==1&playCue==2| catchType =="probe"&load==1&playCue==2)   %>% save1D('delay',dur="tdurdelay","delay_ld1_catchInc_R.1D")
subset(visit,Correct==1&load==3&playCue==1| catchType =="probe"&load==3&playCue==1)   %>% save1D('delay',dur="tdurdelay","delay_ld3_catchInc_L.1D")
subset(visit,Correct==1&load==3&playCue==2| catchType =="probe"&load==3&playCue==2)   %>% save1D('delay',dur="tdurdelay","delay_ld3_catchInc_R.1D")


subset(visit,Correct==1&load==1&playCue==1)   %>% save1D('probe',dur="tdurresp","probe_ld1_Correct_L.1D")
subset(visit,Correct==1&load==1&playCue==2)   %>% save1D('probe',dur="tdurresp","probe_ld1_Correct_R.1D")
subset(visit,Correct==1&load==3&playCue==1)   %>% save1D('probe',dur="tdurresp","probe_ld3_Correct_L.1D")
subset(visit,Correct==1&load==3&playCue==2)   %>% save1D('probe',dur="tdurresp","probe_ld3_Correct_R.1D")

subset(visit,Correct %in% c(-1,0))   %>% save1D('cue',dur="tdur","cue_wrong.1D")
subset(visit,Correct %in% c(-1,0))   %>% save1D('delay',dur="tdurdelay","delay_wrong.1D")
subset(visit,Correct %in% c(-1,0))   %>% save1D('probe',dur="tdurresp","probe_wrong.1D")

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
writeAll1DsWith(fulltrial20160223,outdir='R1D_SPMG3_nomarry')
writeAll1DsWith(lateral_timing,outdir='lateral')
