#this is for Working Memory BA ROIs
library(plyr)
library(ggplot2)

ROIfiles<- Sys.glob('/Volumes/Phillips/P5/scripts/txt/*spheres.txt')

#make a function to read in all the files and select every other one and give column names
test<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/delay_ld1_BA_spheres_t25.txt",header=F)
test2<-test/100
fornames<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/cue_ld1_BA_spheres.txt",header=F)
test3<-cbind(fornames$V1,test2)
colnames(test2)<-c("ID","LBA17_cue_ld1","LBA40_cue_ld1","LBA46_cue_ld1","LBA9_cue_ld1","RBA17_cue_ld1","RBA40_cue_ld1","RBA46_cue_ld1","RBA9_cue_ld1")
colnames(test3)<-c("ID","LBA17_dly_ld3","LBA40_dly_ld3","LBA46_dly_ld3","LBA9_dly_ld3","RBA17_dly_ld3","RBA40_dly_ld3","RBA46_dly_ld3","RBA9_dly_ld3")

colnames(test3)<-c("ID","LBA17_dly_ld1","LBA40_dly_ld1","LBA46_dly_ld1","LBA9_dly_ld1","RBA17_dly_ld1","RBA40_dly_ld1","RBA46_dly_ld1","RBA9_dly_ld1")
colnames(test2)<-c("ID","LBA17_dly_ld1","LBA40_dly_ld1","LBA46_dly_ld1","LBA9_dly_ld1","RBA17_dly_ld1","RBA40_dly_ld1","RBA46_dly_ld1","RBA9_dly_ld1")

#read in google doc
subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt",header=T)
#match the google doc with existing behave files because not all subs completed the tasks
onesIwant<-match(test3$ID,subj$MRID)
#get a new data table with only subs I want
subj2<-subj[onesIwant,]

data_ROIs<-merge(test3,subj2,by.x="ID",by.y="MRID")
#take out the crappy controls
data_ROIs<-data_ROIs[,c(1:9,17,19)]


for (i in 2:9)
  
{
  
  model_beh<-glm(data_ROIs[[i]]~as.factor(data_ROIs$Cohort),data=data_ROIs)
  print((summary(model_beh)$coefficients[2,4]))
}



p.adjust(pvals,method="fdr",n=length(pvals))

setwd("/Users/mariaj/Desktop/")
pdf(paste(todayf,"WM_BA_ROIs_dly_ld3_RBA9_t25.pdf",sep="_"))

cols<-c(9:9)
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
    geom_errorbar(limits, position=dodge, width=0.25,size=1) +
    coord_cartesian(ylim=c(-0.2,0.8))+scale_fill_manual(values=c("light grey","red","gray34")) +
    xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
  p3<-p2+geom_point(data=data_ROIs, aes(x=Cohort,y=RBA9_dly_ld3,colour=Cohort,size=3))+scale_colour_manual(values=c("blue","black"))+geom_point(data=scz, aes(x=Dx,y=RBA9_dly_ld3,size=5),colour="red")+ggtitle("DLPFC")
  print(p3)
}
dev.off()
