#this is for combining WM ROI activation w/ behavior data 
#
library(plyr)
library(ggplot2)
library(dplyr)
library(tidyr)


ste <- function(x) sd(x)/sqrt(length(x))

# BA to name
renameROI <- function(roi) {
   ifelse(roi=='BA17', 'V1',
    ifelse(roi=='BA40','PPC',
    ifelse(roi=='BA9','DLPFC',
    roi)))
}


#  how to read in a load file
#  - define row names (ROIs)
#  - get column names (subj IDs)
#  - make %, set load and ID, set row names
ROIs <- c("LBA17","LBA40","LBA46","LBA9","RBA17","RBA40","RBA46","RBA9")
IDs <- as.character(read.delim("/Users/mariaj/Dropbox/cue_ld1_BA_spheres.txt",header=F)$V1)
readLoadFile <- function(ld) {
      setNames(cbind(IDs,ld,read.delim(file=sprintf("/Users/mariaj/Dropbox/delay_ld%d_BA_spheres_t25.txt",ld),header=F)/100), c('ID','Load',ROIs))
}

#######


# read in both loads, sep. side from ROI name
d <- rbind(readLoadFile(1), readLoadFile(3)) %>% 
 gather(ROI,val,-Load,-ID) %>%
 separate(ROI,c('Side','ROI'),1) 

# name and subset some of the ROIs
d.renamed <- d %>%
 mutate(ROI=renameROI(ROI)) %>% 
 filter(ROI %in% c('V1','PPC','DLPFC')) 
d.renamed$ROI=factor(d.renamed$ROI,levels=list('V1', 'PPC','DLPFC'),labels=list('V1', 'PPC','DLPFC'))
      

# get cohort info into ROIs
cohortinfo <- read.table('/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt',sep="\t",header=T) %>% select(MRID,Cohort)
d.cohort <- merge(d.renamed,cohortinfo,by.x='ID',by.y='MRID')

# get mean and std error
d.sum <- d.cohort %>% 
  group_by(ROI,Load,Side,Cohort) %>% 
  summarize_each(funs(mean,ste),val)

## FACET
p<- ggplot(d.sum) + 
 aes(x=ROI,y=mean,color=Cohort,fill=Cohort,group=Cohort) +
 geom_bar(stat='identity',position='dodge') +
 geom_errorbar(aes(ymin=mean-ste,ymax=mean+ste),position=position_dodge(.9),color='black',width=.25)+
 facet_grid(Load~Side) + 
 theme_bw()

ggsave(p,file='/Volumes/Phillips/P5/scripts/Rplots/imgs/ROI_Means_facet_sideByLoad.pdf')

### INDIVIDUAL LOAD+SIDE
#  save a pdf for each and a merged pdf

# for testting
LD=1; SD='L'

pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/ROIMeans_idv_load_side.pdf')

xlab<-"Brain Region"
ylab<-"Parameter Estimate"
textSize=24
for (LD in c(1,3)) { 
 for (SD in c('L','R')) {
  p<-subset(d.sum, Load==LD&Side==SD) %>%
    ggplot() + 
    aes(x=ROI,y=mean,fill=Cohort,group=Cohort) +
    geom_bar(stat='identity',position='dodge') +
    geom_errorbar(aes(ymin=mean-ste,ymax=mean+ste),position=position_dodge(.9),color='black',width=.25)+
    ggtitle(sprintf("Load %d %s Side",LD,SD)) +scale_fill_manual(values = c("light grey","gray34"))+labs(x=(xlab), y=(ylab))+theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+coord_cartesian(ylim=c(0.0,0.5))
  ggsave(p,file=sprintf("/Volumes/Phillips/P5/scripts/Rplots/imgs/ROI_Means_ld%dsd%s.pdf",LD,SD))
  print(p)
 }
}

dev.off()


#for more refined dx
cohortinfo <- read.table('/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt',sep="\t",header=T) %>% select(MRID,confirmed_initial_dx1)
d.dx <- merge(d.renamed,cohortinfo,by.x='ID',by.y='MRID')

# get mean and std error
d.sum.dx <- d.dx %>% 
  group_by(Side,ROI,confirmed_initial_dx1) %>% 
  summarize_each(funs(mean,ste),val)

d.sum.dx$confirmed_initial_dx1<-as.factor(d.sum.dx$confirmed_initial_dx1)
#reorder
d.sum.dx$confirmed_initial_dx1=factor(d.sum.dx$confirmed_initial_dx1,levels=list('1', '2','4','3'),labels=list('1', '2','4','3'))


# for testting
SD='L'

pdf('/Volumes/Phillips/P5/scripts/Rplots/imgs/Means_idv_load_side_dx.pdf')

xlab<-""
ylab<-"Parameter Estimate"
textSize=24
for (LD in c(1,3)) { 
  for (SD in c('L','R')) {
    p<-subset(d.sum.dx,Side==SD) %>%
      ggplot() + 
      aes(x=ROI,y=mean,fill=confirmed_initial_dx1,group=confirmed_initial_dx1) +
      geom_bar(stat='identity',position='dodge',colour="black") +
      geom_errorbar(aes(ymin=mean-ste,ymax=mean+ste),position=position_dodge(.9),color='black',width=.25)+
      ggtitle(sprintf("Load %d %s Side",LD,SD)) +scale_fill_manual(values = c("red","white","gray40","black"))+labs(x=(xlab), y=(ylab))+theme_bw(base_size=textSize)+theme(panel.border = element_blank(), panel.grid.major = element_blank(),panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+theme(legend.position="none")+coord_cartesian(ylim=c(0.0,0.8))
    ggsave(p,file=sprintf("/Volumes/Phillips/P5/scripts/Rplots/imgs/task_Means_%d%s_dx.pdf",LD,SD))
    print(p)
  }
}

dev.off()
