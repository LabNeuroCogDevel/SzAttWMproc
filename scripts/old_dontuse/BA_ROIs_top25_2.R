#this is for combining WM ROI activation w/ behavior data 
#
library(plyr)
library(ggplot2)
library(dplyr)

delay_ld1<-read.delim(file="/Users/mariaj/Dropbox/delay_ld1_BA_spheres_t25.txt",header=F)
delay_ld1<-delay_ld1/100
fornames<-read.delim(file="/Users/mariaj/Dropbox/cue_ld1_BA_spheres.txt",header=F)
delay_ld1.1<-cbind(fornames$V1,delay_ld1)
colnames(delay_ld1.1)<-c("ID","LBA17_delay_ld1","LBA40_delay_ld1","LBA46_cue_ld1","LBA9_cue_ld1","RBA17_cue_ld1","RBA40_cue_ld1","RBA46_cue_ld1","RBA9_cue_ld1")

#take out the crappy controls


delay_ld1.2<-delay_ld1.1[c(1:25,27:30,32:43),]

#read in google doc
subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt",sep=" ")
onesIwant<-match(delay_ld1.2$ID,subj$subjid)

#check to make sure it got everyone
onesIwant

#get a new data table with only subs I want
subj2<-subj[onesIwant,]

data_ROIs<-merge(delay_ld1.2,subj2,by.x="ID",by.y="subjid")



for (i in 2:9)
  
{
  
  model_beh<-glm(data_ROIs[[i]]~as.factor(data_ROIs$Cohort),data=data_ROIs)
  print((summary(model_beh)$coefficients[2,4]))
}

std <- function(x) sd(x)/sqrt(length(x))

#new data table name
# put all % correct into one column (and load into another)
dt_RTAccLong <- data_ROIs %>% 
 gather(Load,) 

#take out "Load" and just leave it w/ the #s

dt_RTAccLong.1<-dt_RTAccLong %>%
mutate(Load=gsub('.*(\\d).*','\\1',Load))

dt_RTAccLong.2<-dt_RTAccLong.1 %>% 
  gather(LoadRT,RT,avg_RT_ld1,avg_RT_ld3)

dt_RTAccLong.3<-dt_RTAccLong.2 %>% 
  mutate(LoadRT=gsub('.*(\\d).*','\\1',LoadRT)) 

# only grab rows where load matches 
dt_RTAccLong.4<-dt_RTAccLong.3%>%filter(LoadRT==Load)
#remove redudant load info
dt_RTAccLong.5<-dt_RTAccLong.4%>% 
  select(-LoadRT)

# put RT and correct into the same column (as meassures)
dt_RTAccLong.6<-dt_RTAccLong.5  %>% gather(measure,val,Correct,RT)

dt_RTAccLong.7<-dt_RTAccLong.6 %>%
  mutate( Dx = factor(confirmed_initial_dx,labels=list('SCZ','Other','Control','Unconfirmed')) )

# get mean and sterror
RTAccsmy <- dt_RTAccLong.7 %>% group_by(Cohort,Load,measure)

#val goes away????
RTAccsmy.1<-RTAccsmy%>% summarise_each(funs(mean,std),val)

textSize <- 26
wp<- ggplot(RTAccsmy.1) + 
  aes(y=mean,x=Load,fill=Cohort) +
  geom_bar(stat='identity',position='dodge') +scale_fill_manual(values=c("light grey","gray34"))+
  geom_errorbar(aes(ymin=mean-std,ymax=mean+std),position=position_dodge(.9),width=0.25) + 
  geom_point(data=dt_RTAccLong.7,
             position=position_jitterdodge(jitter.width=.4, dodge.width=.9),
             aes(color=Dx,group=Cohort,y=val),alpha=.8,size=3) + theme_bw(base_size=textSize)+theme(legend.position="none")+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+
  facet_grid(measure~.,scales='free_y') +
  scale_color_manual(values=c("red","yellow","black","purple"))

wp

wpl <- lunaize(wp)


cols<-c(8:8)
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
  p3<-p2+geom_point(data=data_ROIs, aes(x=Cohort,y=RBA9_dly_ld1,colour=Cohort,size=3))+scale_colour_manual(values=c("blue","black"))+geom_point(data=scz, aes(x=Dx,y=RBA9_dly_ld1,size=5),colour="red")+ggtitle("DLPFC")
  print(p3)
}
dev.off()
