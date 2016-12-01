#Freesurfer ENIGMA outlier detection (last update Mar 24 2014)


#Read in the cortical thickness measures obtained from Step 1 of the protocols
#dat=read.csv("/Users/mariaj/Dropbox/CorticalMeasuresPNC_ThickAvg.csv",stringsAsFactors=FALSE)
#dat=read.csv("/Users/mariaj/Dropbox/CorticalMeasuresPNC_ThickAvg_BH.csv",stringsAsFactors=FALSE)
#dat=read.csv("/Users/mariaj/Dropbox/CorticalMeasuresPNC_VolAvg.csv",stringsAsFactors=FALSE)
#dat=read.csv("/Users/mariaj/Dropbox/CorticalMeasuresPNC_VolAvg_BH.csv",stringsAsFactors=FALSE)
#dat=read.csv("/Users/mariaj/Dropbox/CorticalMeasuresPNC_SAAvg.csv",stringsAsFactors=FALSE)
#dat=read.csv("/Users/mariaj/Dropbox/SubcorticalMeasures_PNC.csv",stringsAsFactors=FALSE)
dat=read.csv("/Users/mariaj/Dropbox/SubcorticalMeasures_PNC_BH.csv",stringsAsFactors=FALSE)


#Check for duplicated SubjIDs
if(anyDuplicated(dat[,c("SubjID")]) != 0) { stop('You have duplicate SubjIDs in your CorticalMeasuresPNC_ThickAvg.csv file.\nMake sure there are no repeat SubjIDs.') }

#Store the lower and upper limits
lower=rep(NA,ncol(dat)-1)
upper=rep(NA,ncol(dat)-1)

#Loop through the different structures
for(x in 2:ncol(dat)){
  lower[x-1] = mean(dat[,x]) - 2.698*sd(dat[,x])
  upper[x-1] = mean(dat[,x]) + 2.698*sd(dat[,x])
}


cat('Please check the following subjects closely using the QC methods provided in Step 2 of the cortical protocols.\n')

#Loop through each subject report which structures are outliers
for(i in 1:nrow(dat)){
  
  lowind=which(dat[i,-1] < lower)
  upind=which(dat[i,-1] > upper)
  
  if(length(lowind) > 0){
    cat(paste('Subject ', dat[i,1], ' has values too LOW for the following structures: ', names(dat)[lowind + 1], '\n', sep=''))
  }
  if(length(upind) > 0){
    cat(paste('Subject ', dat[i,1], ' has values too HIGH for the following structures: ', names(dat)[upind + 1], '\n', sep=''))
  }
}
