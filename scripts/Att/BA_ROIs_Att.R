#this is for Working Memory BA ROIs
library(plyr)
library(ggplot2)

ROIs<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/all_att_ROIs_11454.txt")
#ROIs<-read.delim(file="/Volumes/Phillips/P5/scripts/txt/all_ROIs_bl.txt")
#read in google doc
subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet.txt",header=T)
#match the google doc with existing behave files because not all subs completed the tasks
onesIwant<-match(ROIs$ID,subj$MRID)
#get a new data table with only subs I want
subj2<-subj[onesIwant,]

data_ROIs<-merge(ROIs,subj2,by.x="ID",by.y="MRID")



for (i in 2:25)
  
{
  
  model_beh<-glm(data_ROIs[[i]]~as.factor(data_ROIs$Cohort),data=data_ROIs)
  print((summary(model_beh)$coefficients[2,4]))
}

pvals<-c(0.5976745,0.4083006,0.9865476,0.4678986,0.1485021,0.2081092,0.984437,0.4955243,0.1022909,0.03250094,0.06499041,0.01673076,0.8346251,0.3345144,0.1850817,0.0875587)

p.adjust(pvals,method="fdr",n=length(pvals))

std <- function(x) sd(x)/sqrt(length(x))

pdf(paste(todayf,"Att_BA_ROIs.pdf",sep="_"))

cols<-c(2:25)
for (i in colnames(data_ROIs)[cols])
{
  
  
  textSize <- 20
  dodge <- position_dodge(width=0.9)
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
  graph_data<-data.frame(group=factor(c("First Episode","Control")), mean=c(means))
  xlab <- "Group"
  ylab= i
  limits <- aes(ymax=means+sem, ymin=means-sem)
  range2 <- range(means + 2*sem, means - 2*sem)
  p <- ggplot(data=graph_data, aes(x=group, y=means,fill=group))
  p2<-p+geom_bar(stat="identity",position=dodge)+
    geom_errorbar(limits, position=dodge, width=0.25,size=1) +
    coord_cartesian(ylim=c(-10,20))+scale_fill_manual(values=c("light grey","gray34")) +
    xlab(xlab) + ylab(ylab) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
  print(p2)
}
dev.off()
