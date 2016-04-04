#this is for combining WM ROI activation w/ behavior data 
#
library(plyr)
library(ggplot2)
library(dplyr)

today<-Sys.Date()
todayf<-format(today,format="%Y%m%d")

std <- function(x) sd(x)/sqrt(length(x))

delay1_ld1_amp<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/delay1_ld1_amp_BA_spheres.txt",header=F)

delay1_ld1_amp.1<-delay1_ld1_amp[,c(1,2,4,6,8,10,12,14,16)]

colnames(delay1_ld1_amp.1)<-c("ID","LBA17_dly1_ld1_amp","LBA40_dly1_ld1_amp","LBA46_dly1_ld1_amp","LBA9_dly1_ld1_amp","RBA17_dly1_ld1_amp","RBA40_dly1_ld1_amp","RBA46_dly1_ld1_amp","RBA9_dly1_ld1_amp")



delay1_ld1_amp.2<-delay1_ld1_amp.1[c(1:25,27:30,32:43),]

#read in google doc
subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt")
onesIwant<-match(delay1_ld1_amp.2$ID,subj$MRID)

#check to make sure it got everyone
onesIwant

#get a new data table with only subs I want
subj2<-subj[onesIwant,]

data_ROIs<-merge(delay1_ld1_amp.2,subj2,by.x="ID",by.y="MRID")



for (i in 2:9)
  
{
  
  model_beh<-glm(data_ROIs[[i]]~as.factor(data_ROIs$Cohort),data=data_ROIs)
  print((summary(model_beh)$coefficients[2,4]))
}


pdf(paste(todayf,"delay1_ld1_amp-test.pdf",sep="_"))

cols<-c(2:9)
for (i in colnames(data_ROIs)[cols])
{
  
  
  textSize <- 26
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_ROIs[,i], data_ROIs$Cohort, mean,na.rm=TRUE))
  
  means<-(tapply(data_ROIs[,i], data_ROIs$Cohort, mean,na.rm=TRUE))
  means<-(as.vector(means))
  pat<-data_ROIs[data_ROIs$Cohort=="Clinical",]
  con<-data_ROIs[data_ROIs$Cohort=="Control",]
  sem1<-sd(pat[,i])/sqrt(27)
  sem2<-sd(con[,i])/sqrt(14)
  sem<-cbind(sem1,sem2)
  colnames(sem)<-c("Clinical","Control")
  sem<-as.vector(sem)
  group<-"Clinical, Control"
  graph_data<-data.frame(group=factor(c("Clinical","Control")), mean=c(means))
  scz<-data_ROIs[data_ROIs$Dx==1,]
  scz<-as.data.frame(scz)
  scz$Dx<-gsub("1","Clinical",scz$Dx)
  xlab <- "Group"
  ylab<-"Parameter Estimate"
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,fill=group))
  p2<-p+geom_bar(stat="identity",position=dodge)+
    geom_errorbar(limits, position=dodge, width=0.25,size=1) +scale_fill_manual(values=c("light grey","red","gray34")) +
    xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+ggtitle(i)
  print(p2)
}
dev.off()









delay1_ld1_lat<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/delay1_ld1_late_BA_spheres.txt",header=F)

delay1_ld1_lat.1<-delay1_ld1_lat[,c(1,2,4,6,8,10,12,14,16)]

colnames(delay1_ld1_lat.1)<-c("ID","LBA17_dly1_ld1_lat","LBA40_dly1_ld1_lat","LBA46_dly1_ld1_lat","LBA9_dly1_ld1_lat","RBA17_dly1_ld1_lat","RBA40_dly1_ld1_lat","RBA46_dly1_ld1_lat","RBA9_dly1_ld1_lat")



delay1_ld1_lat.2<-delay1_ld1_lat.1[c(1:25,27:30,32:43),]

#read in google doc
subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt")
onesIwant<-match(delay1_ld1_lat.2$ID,subj$MRID)

#check to make sure it got everyone
onesIwant

#get a new data table with only subs I want
subj2<-subj[onesIwant,]

data_ROIs2<-merge(delay1_ld1_lat.2,subj2,by.x="ID",by.y="MRID")



for (i in 2:9)
  
{
  
  model_beh<-glm(data_ROIs2[[i]]~as.factor(data_ROIs2$Cohort),data=data_ROIs)
  print((summary(model_beh)$coefficients[2,4]))
}


pdf(paste(todayf,"delay1_ld1_lat.pdf",sep="_"))

cols<-c(2:9)
for (i in colnames(data_ROIs2)[cols])
{
  
  
  textSize <- 26
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_ROIs2[,i], data_ROIs2$Cohort, mean,na.rm=TRUE))
  
  means<-(tapply(data_ROIs2[,i], data_ROIs2$Cohort, mean,na.rm=TRUE))
  means<-(as.vector(means))
  pat<-data_ROIs2[data_ROIs2$Cohort=="Clinical",]
  con<-data_ROIs2[data_ROIs2$Cohort=="Control",]
  sem1<-sd(pat[,i])/sqrt(27)
  sem2<-sd(con[,i])/sqrt(14)
  sem<-cbind(sem1,sem2)
  colnames(sem)<-c("Clinical","Control")
  sem<-as.vector(sem)
  group<-"Clinical, Control"
  graph_data<-data.frame(group=factor(c("Clinical","Control")), mean=c(means))
  scz<-data_ROIs2[data_ROIs2$Dx==1,]
  scz<-as.data.frame(scz)
  scz$Dx<-gsub("1","Clinical",scz$Dx)
  xlab <- "Group"
  ylab<-"Parameter Estimate"
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,fill=group))
  p2<-p+geom_bar(stat="identity",position=dodge)+
    geom_errorbar(limits, position=dodge, width=0.25,size=1) +scale_fill_manual(values=c("light grey","red","gray34")) +
    xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+ggtitle(i)
  print(p2)
}
dev.off()


#delay 3 load 1
delay3_ld1_amp<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/delay3_ld1_amp_BA_spheres.txt",header=F)

delay3_ld1_amp.1<-delay3_ld1_amp[,c(1,2,4,6,8,10,12,14,16)]

colnames(delay3_ld1_amp.1)<-c("ID","LBA17_dly3_ld1_amp","LBA40_dly3_ld1_amp","LBA46_dly3_ld1_amp","LBA9_dly3_ld1_amp","RBA17_dly3_ld1_amp","RBA40_dly3_ld1_amp","RBA46_dly3_ld1_amp","RBA9_dly3_ld1_amp")



delay3_ld1_amp.2<-delay3_ld1_amp.1[c(1:25,27:30,32:43),]

#read in google doc
subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt")
onesIwant<-match(delay3_ld1_amp.2$ID,subj$MRID)

#check to make sure it got everyone
onesIwant

#get a new data table with only subs I want
subj2<-subj[onesIwant,]

data_ROIs<-merge(delay3_ld1_amp.2,subj2,by.x="ID",by.y="MRID")



for (i in 2:9)
  
{
  
  model_beh<-glm(data_ROIs[[i]]~as.factor(data_ROIs$Cohort),data=data_ROIs)
  print((summary(model_beh)$coefficients[2,4]))
}


pdf(paste(todayf,"delay3_ld1_amp.pdf",sep="_"))

cols<-c(2:9)
for (i in colnames(data_ROIs)[cols])
{
  
  
  textSize <- 26
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_ROIs[,i], data_ROIs$Cohort, mean,na.rm=TRUE))
  
  means<-(tapply(data_ROIs[,i], data_ROIs$Cohort, mean,na.rm=TRUE))
  means<-(as.vector(means))
  pat<-data_ROIs[data_ROIs$Cohort=="Clinical",]
  con<-data_ROIs[data_ROIs$Cohort=="Control",]
  sem1<-sd(pat[,i])/sqrt(27)
  sem2<-sd(con[,i])/sqrt(14)
  sem<-cbind(sem1,sem2)
  colnames(sem)<-c("Clinical","Control")
  sem<-as.vector(sem)
  group<-"Clinical, Control"
  graph_data<-data.frame(group=factor(c("Clinical","Control")), mean=c(means))
  scz<-data_ROIs[data_ROIs$Dx==1,]
  scz<-as.data.frame(scz)
  scz$Dx<-gsub("1","Clinical",scz$Dx)
  xlab <- "Group"
  ylab<-"Parameter Estimate"
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,fill=group))
  p2<-p+geom_bar(stat="identity",position=dodge)+
    geom_errorbar(limits, position=dodge, width=0.25,size=1) +scale_fill_manual(values=c("light grey","red","gray34")) +
    xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+ggtitle(i)
  
  print(p2)
}
dev.off()






delay3_ld1_lat<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/delay3_ld1_late_BA_spheres.txt",header=F)

delay3_ld1_lat.1<-delay3_ld1_lat[,c(1,2,4,6,8,10,12,14,16)]

colnames(delay3_ld1_lat.1)<-c("ID","LBA17_dly3_ld1_lat","LBA40_dly3_ld1_lat","LBA46_dly3_ld1_lat","LBA9_dly3_ld1_lat","RBA17_dly3_ld1_lat","RBA40_dly3_ld1_lat","RBA46_dly3_ld1_lat","RBA9_dly3_ld1_lat")



delay3_ld1_lat.2<-delay3_ld1_lat.1[c(1:25,27:30,32:43),]

#read in google doc
subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt")
onesIwant<-match(delay3_ld1_lat.2$ID,subj$MRID)

#check to make sure it got everyone
onesIwant

#get a new data table with only subs I want
subj2<-subj[onesIwant,]

data_ROIs<-merge(delay3_ld1_lat.2,subj2,by.x="ID",by.y="MRID")



for (i in 2:9)
  
{
  
  model_beh<-glm(data_ROIs[[i]]~as.factor(data_ROIs$Cohort),data=data_ROIs)
  print((summary(model_beh)$coefficients[2,4]))
}


pdf(paste(todayf,"delay3_ld1_latency.pdf",sep="_"))

cols<-c(2:9)
for (i in colnames(data_ROIs)[cols])
{
  
  
  textSize <- 26
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_ROIs[,i], data_ROIs$Cohort, mean,na.rm=TRUE))
  
  means<-(tapply(data_ROIs[,i], data_ROIs$Cohort, mean,na.rm=TRUE))
  means<-(as.vector(means))
  pat<-data_ROIs[data_ROIs$Cohort=="Clinical",]
  con<-data_ROIs[data_ROIs$Cohort=="Control",]
  sem1<-std(pat[,i])
  sem2<-std(con[,i])
  sem<-cbind(sem1,sem2)
  colnames(sem)<-c("Clinical","Control")
  sem<-as.vector(sem)
  group<-"Clinical, Control"
  graph_data<-data.frame(group=factor(c("Clinical","Control")), mean=c(means))
  scz<-data_ROIs[data_ROIs$Dx==1,]
  scz<-as.data.frame(scz)
  scz$Dx<-gsub("1","Clinical",scz$Dx)
  xlab <- "Group"
  ylab<-"Parameter Estimate"
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,fill=group))
  p2<-p+geom_bar(stat="identity",position=dodge)+
    geom_errorbar(limits, position=dodge, width=0.25,size=1) +scale_fill_manual(values=c("light grey","red","gray34")) +
    xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+ggtitle(i)
  #p3<-p2+geom_point(data=data_ROIs, aes(x=Cohort,y=i,colour=Cohort,size=3))+scale_colour_manual(values=c("blue","black"))+geom_point(data=scz, aes(x=Dx,y=i,size=5),colour="red")
  print(p2)
}
dev.off()


delay1_ld3_amp<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/delay1_ld3_amp_BA_spheres.txt",header=F)

delay1_ld3_amp.1<-delay1_ld3_amp[,c(1,2,4,6,8,10,12,14,16)]

colnames(delay1_ld3_amp.1)<-c("ID","LBA17_dly1_ld3_amp","LBA40_dly1_ld3_amp","LBA46_dly1_ld3_amp","LBA9_dly1_ld3_amp","RBA17_dly1_ld3_amp","RBA40_dly1_ld3_amp","RBA46_dly1_ld3_amp","RBA9_dly1_ld3_amp")



delay1_ld3_amp.2<-delay1_ld3_amp.1[c(1:25,27:30,32:43),]

#read in google doc
subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt")
onesIwant<-match(delay1_ld3_amp.2$ID,subj$MRID)

#check to make sure it got everyone
onesIwant

#get a new data table with only subs I want
subj2<-subj[onesIwant,]

data_ROIs<-merge(delay1_ld3_amp.2,subj2,by.x="ID",by.y="MRID")



for (i in 2:9)
  
{
  
  model_beh<-glm(data_ROIs[[i]]~as.factor(data_ROIs$Cohort),data=data_ROIs)
  print((summary(model_beh)$coefficients[2,4]))
}


pdf(paste(todayf,"delay1_ld3_amp.pdf",sep="_"))

cols<-c(2:9)
for (i in colnames(data_ROIs)[cols])
{
  
  
  textSize <- 26
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_ROIs[,i], data_ROIs$Cohort, mean,na.rm=TRUE))
  
  means<-(tapply(data_ROIs[,i], data_ROIs$Cohort, mean,na.rm=TRUE))
  means<-(as.vector(means))
  pat<-data_ROIs[data_ROIs$Cohort=="Clinical",]
  con<-data_ROIs[data_ROIs$Cohort=="Control",]
  sem1<-sd(pat[,i])/sqrt(27)
  sem2<-sd(con[,i])/sqrt(14)
  sem<-cbind(sem1,sem2)
  colnames(sem)<-c("Clinical","Control")
  sem<-as.vector(sem)
  group<-"Clinical, Control"
  graph_data<-data.frame(group=factor(c("Clinical","Control")), mean=c(means))
  scz<-data_ROIs[data_ROIs$Dx==1,]
  scz<-as.data.frame(scz)
  scz$Dx<-gsub("1","Clinical",scz$Dx)
  xlab <- "Group"
  ylab<-"Parameter Estimate"
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,fill=group))
  p2<-p+geom_bar(stat="identity",position=dodge)+
    geom_errorbar(limits, position=dodge, width=0.25,size=1) +scale_fill_manual(values=c("light grey","red","gray34")) +
    xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+ggtitle(i)
  print(p2)
}
dev.off()









delay1_ld3_lat<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/delay1_ld3_late_BA_spheres.txt",header=F)

delay1_ld3_lat.1<-delay1_ld3_lat[,c(1,2,4,6,8,10,12,14,16)]

colnames(delay1_ld3_lat.1)<-c("ID","LBA17_dly1_ld3_lat","LBA40_dly1_ld3_lat","LBA46_dly1_ld3_lat","LBA9_dly1_ld3_lat","RBA17_dly1_ld3_lat","RBA40_dly1_ld3_lat","RBA46_dly1_ld3_lat","RBA9_dly1_ld3_lat")



delay1_ld3_lat.2<-delay1_ld3_lat.1[c(1:25,27:30,32:43),]

#read in google doc
subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt")
onesIwant<-match(delay1_ld3_lat.2$ID,subj$MRID)

#check to make sure it got everyone
onesIwant

#get a new data table with only subs I want
subj2<-subj[onesIwant,]

data_ROIs2<-merge(delay1_ld3_lat.2,subj2,by.x="ID",by.y="MRID")



for (i in 2:9)
  
{
  
  model_beh<-glm(data_ROIs2[[i]]~as.factor(data_ROIs2$Cohort),data=data_ROIs)
  print((summary(model_beh)$coefficients[2,4]))
}


pdf(paste(todayf,"delay1_ld3_lat.pdf",sep="_"))

cols<-c(2:9)
for (i in colnames(data_ROIs2)[cols])
{
  
  
  textSize <- 26
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_ROIs2[,i], data_ROIs2$Cohort, mean,na.rm=TRUE))
  
  means<-(tapply(data_ROIs2[,i], data_ROIs2$Cohort, mean,na.rm=TRUE))
  means<-(as.vector(means))
  pat<-data_ROIs2[data_ROIs2$Cohort=="Clinical",]
  con<-data_ROIs2[data_ROIs2$Cohort=="Control",]
  sem1<-sd(pat[,i])/sqrt(27)
  sem2<-sd(con[,i])/sqrt(14)
  sem<-cbind(sem1,sem2)
  colnames(sem)<-c("Clinical","Control")
  sem<-as.vector(sem)
  group<-"Clinical, Control"
  graph_data<-data.frame(group=factor(c("Clinical","Control")), mean=c(means))
  scz<-data_ROIs2[data_ROIs2$Dx==1,]
  scz<-as.data.frame(scz)
  scz$Dx<-gsub("1","Clinical",scz$Dx)
  xlab <- "Group"
  ylab<-"Parameter Estimate"
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,fill=group))
  p2<-p+geom_bar(stat="identity",position=dodge)+
    geom_errorbar(limits, position=dodge, width=0.25,size=1) +scale_fill_manual(values=c("light grey","red","gray34")) +
    xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+ggtitle(i)
  print(p2)
}
dev.off()





delay3_ld3_amp<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/delay3_ld3_amp_BA_spheres.txt",header=F)

delay3_ld3_amp.1<-delay3_ld3_amp[,c(1,2,4,6,8,10,12,14,16)]

colnames(delay3_ld3_amp.1)<-c("ID","LBA17_dly3_ld3_amp","LBA40_dly3_ld3_amp","LBA46_dly3_ld3_amp","LBA9_dly3_ld3_amp","RBA17_dly3_ld3_amp","RBA40_dly3_ld3_amp","RBA46_dly3_ld3_amp","RBA9_dly3_ld3_amp")



delay3_ld3_amp.2<-delay3_ld3_amp.1[c(1:25,27:30,32:43),]

#read in google doc
subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt")
onesIwant<-match(delay3_ld3_amp.2$ID,subj$MRID)

#check to make sure it got everyone
onesIwant

#get a new data table with only subs I want
subj2<-subj[onesIwant,]

data_ROIs<-merge(delay3_ld3_amp.2,subj2,by.x="ID",by.y="MRID")



for (i in 2:9)
  
{
  
  model_beh<-glm(data_ROIs[[i]]~as.factor(data_ROIs$Cohort),data=data_ROIs)
  print((summary(model_beh)$coefficients[2,4]))
}


pdf(paste(todayf,"delay3_ld3_amp.pdf",sep="_"))

cols<-c(2:9)
for (i in colnames(data_ROIs)[cols])
{
  
  
  textSize <- 26
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_ROIs[,i], data_ROIs$Cohort, mean,na.rm=TRUE))
  
  means<-(tapply(data_ROIs[,i], data_ROIs$Cohort, mean,na.rm=TRUE))
  means<-(as.vector(means))
  pat<-data_ROIs[data_ROIs$Cohort=="Clinical",]
  con<-data_ROIs[data_ROIs$Cohort=="Control",]
  sem1<-sd(pat[,i])/sqrt(27)
  sem2<-sd(con[,i])/sqrt(14)
  sem<-cbind(sem1,sem2)
  colnames(sem)<-c("Clinical","Control")
  sem<-as.vector(sem)
  group<-"Clinical, Control"
  graph_data<-data.frame(group=factor(c("Clinical","Control")), mean=c(means))
  scz<-data_ROIs[data_ROIs$Dx==1,]
  scz<-as.data.frame(scz)
  scz$Dx<-gsub("1","Clinical",scz$Dx)
  xlab <- "Group"
  ylab<-"Parameter Estimate"
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,fill=group))
  p2<-p+geom_bar(stat="identity",position=dodge)+
    geom_errorbar(limits, position=dodge, width=0.25,size=1) +scale_fill_manual(values=c("light grey","red","gray34")) +
    xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+ggtitle(i)
  print(p2)
}
dev.off()



delay3_ld3_lat<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/delay3_ld3_late_BA_spheres.txt",header=F)

delay3_ld3_lat.1<-delay3_ld3_lat[,c(1,2,4,6,8,10,12,14,16)]

colnames(delay3_ld3_lat.1)<-c("ID","LBA17_dly3_ld3_lat","LBA40_dly3_ld3_lat","LBA46_dly3_ld3_lat","LBA9_dly3_ld3_lat","RBA17_dly3_ld3_lat","RBA40_dly3_ld3_lat","RBA46_dly3_ld3_lat","RBA9_dly3_ld3_lat")



delay3_ld3_lat.2<-delay3_ld3_lat.1[c(1:25,27:30,32:43),]

#read in google doc
subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt")
onesIwant<-match(delay3_ld3_lat.2$ID,subj$MRID)

#check to make sure it got everyone
onesIwant

#get a new data table with only subs I want
subj2<-subj[onesIwant,]

data_ROIs2<-merge(delay3_ld3_lat.2,subj2,by.x="ID",by.y="MRID")



for (i in 2:9)
  
{
  
  model_beh<-glm(data_ROIs2[[i]]~as.factor(data_ROIs2$Cohort),data=data_ROIs)
  print((summary(model_beh)$coefficients[2,4]))
}


pdf(paste(todayf,"delay3_ld3_lat.pdf",sep="_"))

cols<-c(2:9)
for (i in colnames(data_ROIs2)[cols])
{
  
  
  textSize <- 26
  dodge <- position_dodge(width=0.9)
  means<-(tapply(data_ROIs2[,i], data_ROIs2$Cohort, mean,na.rm=TRUE))
  
  means<-(tapply(data_ROIs2[,i], data_ROIs2$Cohort, mean,na.rm=TRUE))
  means<-(as.vector(means))
  pat<-data_ROIs2[data_ROIs2$Cohort=="Clinical",]
  con<-data_ROIs2[data_ROIs2$Cohort=="Control",]
  sem1<-sd(pat[,i])/sqrt(27)
  sem2<-sd(con[,i])/sqrt(14)
  sem<-cbind(sem1,sem2)
  colnames(sem)<-c("Clinical","Control")
  sem<-as.vector(sem)
  group<-"Clinical, Control"
  graph_data<-data.frame(group=factor(c("Clinical","Control")), mean=c(means))
  scz<-data_ROIs2[data_ROIs2$Dx==1,]
  scz<-as.data.frame(scz)
  scz$Dx<-gsub("1","Clinical",scz$Dx)
  xlab <- "Group"
  ylab<-"Parameter Estimate"
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,fill=group))
  p2<-p+geom_bar(stat="identity",position=dodge)+
    geom_errorbar(limits, position=dodge, width=0.25,size=1) +scale_fill_manual(values=c("light grey","red","gray34")) +
    xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+ggtitle(i)
  print(p2)
}
dev.off()



