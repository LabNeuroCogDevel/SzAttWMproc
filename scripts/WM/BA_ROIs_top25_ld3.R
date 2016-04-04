#this is for combining WM ROI activation w/ behavior data 
#
library(plyr)
library(ggplot2)
library(dplyr)

delay_ld3<-read.delim(file="/Users/mariaj/Dropbox/delay_ld3_BA_spheres_t25.txt",header=F)
delay_ld3<-delay_ld3/100
fornames<-read.delim(file="/Users/mariaj/Dropbox/cue_ld1_BA_spheres.txt",header=F)
delay_ld3.1<-cbind(fornames$V1,delay_ld3)
colnames(delay_ld3.1)<-c("ID","LBA17_delay_ld3","LBA40_delay_ld3","LBA46_delay_ld3","LBA9_delay_ld3","RBA17_delay_ld3","RBA40_delay_ld3","RBA46_delay_ld3","RBA9_delay_ld3")

#take out the crappy controls


delay_ld3.2<-delay_ld3.1[c(1:25,27:30,32:43),]

#read in google doc
subj<-read.delim(file="/Users/mariaj/Dropbox/20160303_behavior_data_demos.txt")


data_ROIs<-merge(delay_ld3.2,subj,by.x="ID",by.y="subjid")
#create bilateral ROIs
data_ROIs$BBA17_delay_ld3<-(data_ROIs$LBA17_delay_ld3+data_ROIs$RBA17_delay_ld3)/2
data_ROIs$BBA40_delay_ld3<-(data_ROIs$LBA40_delay_ld3+data_ROIs$RBA40_delay_ld3)/2
#data_ROIs$BBA46_delay_ld3<-(data_ROIs$LBA46_delay_ld3+data_ROIs$RBA46_delay_ld3)/2
data_ROIs$BBA9_delay_ld3<-(data_ROIs$LBA46_delay_ld3+data_ROIs$RBA9_delay_ld3)/2

write.table(data_ROIs[,c(1,22:24)],file="/Volumes/Phillips/P5/scripts/20160307_BLROIS_ld3.txt")



for (i in 2:9)
  
{
  
  model_beh<-glm(data_ROIs[[i]]~as.factor(data_ROIs$Cohort),data=data_ROIs)
  print((summary(model_beh)$coefficients[2,4]))
}

std <- function(x) sd(x)/sqrt(length(x))


#compare only scz to controls
data_ROIs_dx<-data_ROIs[data_ROIs$confirmed_initial_dx=="1" | data_ROIs$confirmed_initial_dx=="3", ]

for (i in 2:9)
  
{
  
  model_beh<-glm(data_ROIs_dx[[i]]~as.factor(data_ROIs_dx$confirmed_initial_dx),data=data_ROIs_dx)
  print((summary(model_beh)$coefficients[2,4]))
}





symp<-read.delim(file="/Users/mariaj/Dropbox/20160310_symptom_measures.txt")

data_symp<-merge(data_ROIs,symp,by.x="ID",by.y="ID")


cor.test(data_symp$LBA40_delay_ld3,data_symp$AVSN_OITM)
cor.test(data_symp$LBA40_delay_ld3,data_symp$AVSPITM)
cor.test(data_symp$LBA40_delay_ld3,data_symp$SANITM)
cor.test(data_symp$LBA40_delay_ld3,data_symp$SAPITM)
cor.test(data_symp$LBA40_delay_ld3,data_symp$BPRSNGS)
cor.test(data_symp$LBA40_delay_ld3,data_symp$BPRSPOS)
cor.test(data_symp$LBA40_delay_ld3,data_symp$IQ)

cor.test(data_symp$LBA9_delay_ld3,data_symp$AVSN_OITM)
cor.test(data_symp$LBA9_delay_ld3,data_symp$AVSPITM)
cor.test(data_symp$LBA9_delay_ld3,data_symp$SANITM)
cor.test(data_symp$LBA9_delay_ld3,data_symp$SAPITM)
cor.test(data_symp$LBA9_delay_ld3,data_symp$BPRSNGS)
cor.test(data_symp$LBA9_delay_ld3,data_symp$BPRSPOS)
cor.test(data_symp$LBA9_delay_ld3,data_symp$IQ)

cor.test(data_symp$RBA9_delay_ld3,data_symp$AVSN_OITM)
cor.test(data_symp$RBA9_delay_ld3,data_symp$AVSPITM)
cor.test(data_symp$RBA9_delay_ld3,data_symp$SANITM)
cor.test(data_symp$RBA9_delay_ld3,data_symp$SAPITM)
cor.test(data_symp$RBA9_delay_ld3,data_symp$BPRSNGS)
cor.test(data_symp$RBA9_delay_ld3,data_symp$BPRSPOS)
cor.test(data_symp$RBA9_delay_ld3,data_symp$IQ)
    
#new data table name
# put all % correct into one column (and load into another)
dt_RTAccLong <- data_ROIs 
dt_RTAccLong.1<-dt_RTAccLong %>%
  mutate( Dx = factor(confirmed_initial_dx,labels=list('SCZ','Other','Control','Unconfirmed')) )
dt_RTAccLong.2<-dt_RTAccLong.1 %>%
  mutate( Cohort = factor(Cohort,labels=list("First Episode","Control")) )

# get mean and sterror
RTAccsmy <- dt_RTAccLong.2 %>% group_by(Cohort)

#put in your region you are interested in 
RTAccsmy.1<-RTAccsmy%>% summarise_each(funs(mean,std),LBA17_delay_ld3)

pdf(paste("LBA17_delay_ld3.pdf",sep="_"))
textSize <- 24
xlab<-" "
ylab<-"Parameter Estimate"
BA_plot<- ggplot(RTAccsmy.1) + 
  aes(y=mean,x=Cohort,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +scale_fill_manual(values=c("light grey","gray34"))+
  geom_errorbar(aes(ymin=mean-std,ymax=mean+std),position=position_dodge(.9),width=0.25) + xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.title=element_blank())+theme(legend.position="none")+coord_cartesian(ylim=c(-0.30,1.0))

BA_plot2<- BA_plot+ geom_point(data=dt_RTAccLong.2,
                               position=position_jitterdodge(jitter.width=.4, dodge.width=.9),
                               aes(color=Dx,group=Cohort,y=LBA17_delay_ld3,shape=Dx),alpha=.8,size=4) +scale_color_manual(values=c("red","black","gray8","gray40"))+scale_shape_manual(values=c(16,1,16,16))

print(BA_plot2)
dev.off()


# get mean and sterror
RTAccsmy <- dt_RTAccLong.2 %>% group_by(Cohort)

#put in your region you are interested in 
RTAccsmy.1<-RTAccsmy%>% summarise_each(funs(mean,std),RBA17_delay_ld3)

pdf(paste("RBA17_delay_ld3.pdf",sep="_"))
textSize <- 24
xlab<-" "
ylab<-"Parameter Estimate"
BA_plot<- ggplot(RTAccsmy.1) + 
  aes(y=mean,x=Cohort,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +scale_fill_manual(values=c("light grey","gray34"))+
  geom_errorbar(aes(ymin=mean-std,ymax=mean+std),position=position_dodge(.9),width=0.25) + xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.title=element_blank())+theme(legend.position="none")+coord_cartesian(ylim=c(-0.30,1.0))

BA_plot2<- BA_plot+ geom_point(data=dt_RTAccLong.2,
                               position=position_jitterdodge(jitter.width=.4, dodge.width=.9),
                               aes(color=Dx,group=Cohort,y=RBA17_delay_ld3,shape=Dx),alpha=.8,size=4) +scale_color_manual(values=c("red","black","gray8","gray40"))+scale_shape_manual(values=c(16,1,16,16))

print(BA_plot2)
dev.off()



# get mean and sterror
RTAccsmy <- dt_RTAccLong.2 %>% group_by(Cohort)

#put in your region you are interested in 
RTAccsmy.1<-RTAccsmy%>% summarise_each(funs(mean,std),LBA40_delay_ld3)

pdf(paste("LBA40_delay_ld3.pdf",sep="_"))
textSize <- 24
xlab<-" "
ylab<-"Parameter Estimate"
BA_plot<- ggplot(RTAccsmy.1) + 
  aes(y=mean,x=Cohort,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +scale_fill_manual(values=c("light grey","gray34"))+
  geom_errorbar(aes(ymin=mean-std,ymax=mean+std),position=position_dodge(.9),width=0.25) + xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.title=element_blank())+theme(legend.position="none")+coord_cartesian(ylim=c(-0.30,1.0))

BA_plot2<- BA_plot+ geom_point(data=dt_RTAccLong.2,
                               position=position_jitterdodge(jitter.width=.4, dodge.width=.9),
                               aes(color=Dx,group=Cohort,y=LBA40_delay_ld3,shape=Dx),alpha=.8,size=4) +scale_color_manual(values=c("red","black","gray8","gray40"))+scale_shape_manual(values=c(16,1,16,16))

print(BA_plot2)
dev.off()


# get mean and sterror
RTAccsmy <- dt_RTAccLong.2 %>% group_by(Cohort)

#put in your region you are interested in 
RTAccsmy.1<-RTAccsmy%>% summarise_each(funs(mean,std),RBA40_delay_ld3)

pdf(paste("RBA40_delay_ld3.pdf",sep="_"))
textSize <- 24
xlab<-" "
ylab<-"Parameter Estimate"
BA_plot<- ggplot(RTAccsmy.1) + 
  aes(y=mean,x=Cohort,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +scale_fill_manual(values=c("light grey","gray34"))+
  geom_errorbar(aes(ymin=mean-std,ymax=mean+std),position=position_dodge(.9),width=0.25) + xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.title=element_blank())+theme(legend.position="none")+coord_cartesian(ylim=c(-0.30,1.0))

BA_plot2<- BA_plot+ geom_point(data=dt_RTAccLong.2,
                               position=position_jitterdodge(jitter.width=.4, dodge.width=.9),
                               aes(color=Dx,group=Cohort,y=RBA40_delay_ld3,shape=Dx),alpha=.8,size=4) +scale_color_manual(values=c("red","black","gray8","gray40"))+scale_shape_manual(values=c(16,1,16,16))

print(BA_plot2)
dev.off()

# get mean and sterror
RTAccsmy <- dt_RTAccLong.2 %>% group_by(Cohort)

#put in your region you are interested in 
RTAccsmy.1<-RTAccsmy%>% summarise_each(funs(mean,std),LBA9_delay_ld3)

pdf(paste("LBA46_delay_ld3.pdf",sep="_"))
textSize <- 24
xlab<-" "
ylab<-"Parameter Estimate"
BA_plot<- ggplot(RTAccsmy.1) + 
  aes(y=mean,x=Cohort,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +scale_fill_manual(values=c("light grey","gray34"))+
  geom_errorbar(aes(ymin=mean-std,ymax=mean+std),position=position_dodge(.9),width=0.25) + xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.title=element_blank())+theme(legend.position="none")+coord_cartesian(ylim=c(-0.30,1.0))

BA_plot2<- BA_plot+ geom_point(data=dt_RTAccLong.2,
                               position=position_jitterdodge(jitter.width=.4, dodge.width=.9),
                               aes(color=Dx,group=Cohort,y=LBA9_delay_ld3,shape=Dx),alpha=.8,size=4) +scale_color_manual(values=c("red","black","gray8","gray40"))+scale_shape_manual(values=c(16,1,16,16))

print(BA_plot2)
dev.off()


# get mean and sterror
RTAccsmy <- dt_RTAccLong.2 %>% group_by(Cohort)

#put in your region you are interested in 
RTAccsmy.1<-RTAccsmy%>% summarise_each(funs(mean,std),RBA9_delay_ld3)

pdf(paste("RBA9delay_ld3.pdf",sep="_"))
textSize <- 24
xlab<-" "
ylab<-"Parameter Estimate"
BA_plot<- ggplot(RTAccsmy.1) + 
  aes(y=mean,x=Cohort,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +scale_fill_manual(values=c("light grey","gray34"))+
  geom_errorbar(aes(ymin=mean-std,ymax=mean+std),position=position_dodge(.9),width=0.25) + xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.title=element_blank())+theme(legend.position="none")+coord_cartesian(ylim=c(-0.30,1.0))

BA_plot2<- BA_plot+ geom_point(data=dt_RTAccLong.2,
                               position=position_jitterdodge(jitter.width=.4, dodge.width=.9),
                               aes(color=Dx,group=Cohort,y=RBA9_delay_ld3,shape=Dx),alpha=.8,size=4) +scale_color_manual(values=c("red","black","gray8","gray40"))+scale_shape_manual(values=c(16,1,16,16))

print(BA_plot2)
dev.off()






