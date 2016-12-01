library(dplyr)
library(ggplot2)
library(lme4)

##### Prepare data 

setwd("/Volumes/Phillips/P5/group_analyses/Att/HRF/")

timeseries<-read.table("allTRs.txt")


names(timeseries)<-c("subj","roi","cond","group","tr","amp")
timeseries$trf<-as.factor(timeseries$tr)
timeseries$group<-as.factor(timeseries$group)
timeseries$groupf<-"Controls"
timeseries$groupf[timeseries$group==1]<-"Patients"

timeseries$hline<-0
#timeseries$amp<-percentsignal(timeseries$amp)

for(condi in 1:3) {
  clustsByCond<-c('pop','hab','flex')
  conds<-c("HRF2_Popout","HRF2_Habitual","HRF2_Flexible")
  nclusts<-c(8,4,1)
  
  for(i in 1:nclusts[condi]) {
    
    roi<-paste(clustsByCond[condi],i,sep="")
    thisroi<-timeseries[timeseries$roi %in% c(roi),]
    thisroi_move<-thisroi[thisroi$cond %in% c(conds[condi]),]
    
    
    ##### Plot group
    
    ROImean<-thisroi_move %>% group_by (tr,groupf) %>% summarize (change=mean(amp),sem=sd(amp)/sqrt(length(amp)))
    
    ROImean$yminvar<-ROImean$change-ROImean$sem
    ROImean$ymaxvar<-ROImean$change+ROImean$sem
    
    ROImean$time<-ROImean$tr*1
    ROImean$time<-ROImean$time
    
    
    gp<-ggplot(ROImean, aes(x=time, y=change,colour=groupf)) + 
      geom_line(stat="identity",position="dodge",size=1) +
      geom_ribbon(aes(ymin=yminvar,ymax=ymaxvar,colour=NA,fill=groupf),linetype=1,alpha=.4) +
      geom_hline(aes(yintercept=0),linetype="dashed") +
      ggtitle(roi)
    
    gp<-gp+scale_colour_manual(values = c("red","steelblue4"))+scale_fill_manual(values = c("red","dodgerblue"))
    
    gp<-gp+theme(legend.title=element_blank())+scale_x_continuous(breaks=c(seq(from = 0 ,to =28, by=4)))
    
    #gp<-gp+theme(legend.position="right")
    #gp
    ggsave(paste(roi,"png",sep="."),gp)
    
    m1<-lmer(amp~group*trf+(1|subj),data=thisroi_move)
    summary(m1)
    car::Anova(m1)
  }
  
}