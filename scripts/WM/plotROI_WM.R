library(dplyr)
library(ggplot2)
library(lme4)
library(LNCDR)

##### Prepare data 

setwd(/Volumes/Phillips/P5/group_analyses/WM/subj1d")

timeseries<-read.table("alltentfiles.txt")
demo_info<-read.delim(file=/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet.txt")
demo_info_sub<-subset(demo_info,select=c("MRID","Cohort"))

names(timeseries)<-c("subj","cond","roi","tr","amp")
 
timeseries_grp<-merge(timeseries,demo_info_sub,by.x="subj",by.y="MRID")
timeseries_grp<-subset(timeseries_grp, subj!='11454_20151019') #subj data not fully preproc


timeseries_grp$amp<-timeseries_grp$amp/100 #preproc gives high numbers, /100 to scale down


timeseries_grp$trf<-as.factor(timeseries_grp$tr)
timeseries_grp$Cohortf<-as.factor(timeseries_grp$Cohort)
timeseries_grp$Cohortf<-"Controls" 
timeseries_grp$Cohortf[timeseries_grp$Cohort=="Clinical"]<-"Patients"

timeseries_grp$hline<-0
#timeseries$amp<-percentsignal(timeseries$amp)

#for(condi in 1:3) {
  #clustsByCond<-c('pop','hab','flex')
  conds<-c("cue_ld1","cue_ld3","delay1_ld1","delay1_ld3","delay3_ld1","delay3_ld3","probe_ld1","probe_ld3")
  rois<-c("LBA17","RBA17","LBA46","RBA46","LBA5","RBA5","LBA7","RBA7","LBA9","RBA9")  #nclusts<-c(8,4,1)
  
  #for(i in 1:nclusts[condi]) {
    
    roi<-paste("LBA7")
    thisroi<-timeseries_grp[timeseries_grp$roi %in% c(roi),]
    cond<-paste("delay3_ld3")
    thisroi_cond<-thisroi[thisroi$cond %in% c(cond),]  #thisroi_move<-thisroi[thisroi$cond %in% c(conds[condi]),]
    #thisroi_cond<-thisroi$cond %in% c(cond) #returns logical vector
    
    
    ##### Plot group
    
    ROImean<-thisroi_cond %>% 
      group_by(tr,Cohortf) %>% #want to group thisroi_cond by TR and by Cohort
      summarize(meanAmp=mean(amp),meanSE=sd(amp)/sqrt(length(amp)))
      #ROImean<-thisroi_cond %>% group_by (tr,groupf) %>% summarize (change=mean(amp),sem=sd(amp)/sqrt(length(amp)))
    
    ROImean$yminvar<-ROImean$meanAmp-ROImean$meanSE #add columns for mins and max
    ROImean$ymaxvar<-ROImean$meanAmp+ROImean$meanSE
    
    ROImean$time<-ROImean$tr*1
    ROImean$time<-ROImean$time
    
    today<-Sys.Date()
    todayf<-format(today,format="%Y%m%d")
    
    pdf(paste(todayf,roi,sep="_"))
    gp<-ggplot(ROImean, aes(x=time, y=meanAmp,colour=Cohortf)) +
      geom_line(stat="identity",position="dodge",size=1) +   #position=position_dodge(width=1)
      geom_ribbon(aes(ymin=yminvar,ymax=ymaxvar,colour=NA,fill=Cohortf),linetype=1,alpha=.4) +
      geom_hline(aes(yintercept=0),linetype="dashed") +
      ggtitle(roi)
    
    gp<-gp+scale_colour_manual(values = c("red","steelblue4"))+scale_fill_manual(values = c("indianred2","dodgerblue"))
    
    gp<-gp+theme(legend.title=element_blank())+scale_x_continuous(breaks=c(seq(from = 0 ,to =28, by=4)))+theme(legend.title=element_blank())
    
    
    #gp2<-lunaize(gp)
    #gp2<-gp2+theme(legend.title=element_blank())
    gp<-gp+theme(legend.title=element_blank())
    
    
    print(gp)
    
    dev.off()
   # ggsave(paste(roi,"png",sep="."),gp2)
    
    m1<-lmer(amp~Cohort*trf+(1|subj),data=thisroi_cond)
    summary(m1)
    car::Anova(m1)
  }
  
}
