#this is for combining WM ROI activation w/ behavior data 
#
library(plyr)
library(ggplot2)
library(dplyr)
library(tidyr)


ste <- function(x) sd(x)/sqrt(length(x))

# BA to name
renameROI <- function(roi) {
   ifelse(roi=='BA17', 'Visual',
    ifelse(roi=='BA40','PPC',
    ifelse(roi=='BA9','DLPFC',
    roi)))
}


#  how to read in a load file
#  - define row names (ROIs)
#  - get column names (subj IDs)
#  - make %, set load and ID, set row names
ROIs <- c("LBA17","LBA40","LBA46","LBA9","RBA17","RBA40","RBA46","RBA9")
IDs <- as.character(read.delim("cue_ld1_BA_spheres.txt",header=F)$V1)
readLoadFile <- function(ld) {
      setNames(cbind(IDs,ld,read.delim(file=sprintf("delay_ld%d_BA_spheres_t25.txt",ld),header=F)/100), c('ID','Load',ROIs))
}

#######


# read in both loads, sep. side from ROI name
d <- rbind(readLoadFile(1), readLoadFile(3)) %>% 
 gather(ROI,val,-Load,-ID) %>%
 separate(ROI,c('Side','ROI'),1) 

# name and subset some of the ROIs
d.renamed <- d %>%
 mutate(ROI=renameROI(ROI)) %>% 
 filter(ROI %in% c('Visual','PPC','DLPFC'))
      

# get cohort info into ROIs
cohortinfo <- read.table('../SubjInfoGoogleSheet.txt',sep="\t",header=T) %>% select(MRID,Cohort)
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

ggsave(p,file='imgs/ROI_Means_facet_sideByLoad.pdf')

### INDIVIDUAL LOAD+SIDE
#  save a pdf for each and a merged pdf

# for testting
LD=1; SD='L'

pdf('imgs/ROIMeans_idv_load_side.pdf')
for (LD in c(1,3)) { 
 for (SD in c('L','R')) {

 p<-subset(d.sum, Load==LD&Side==SD) %>%
   ggplot() + 
   aes(x=ROI,y=mean,color=Cohort,fill=Cohort,group=Cohort) +
   geom_bar(stat='identity',position='dodge') +
   geom_errorbar(aes(ymin=mean-ste,ymax=mean+ste),position=position_dodge(.9),color='black',width=.25)+
   ggtitle(sprintf("Load %d %s Side",LD,SD)) +
   theme_bw()
 ggsave(p,file=sprintf("imgs/ROI_Means_ld%dsd%s.pdf",LD,SD))
 print(p)
}}

dev.off()
