library(car)
library(ggplot2)

subj<-read.delim(file="C:/Users/Dhruv/Documents/GitHub/SzAttWMproc/scripts/SubjInfoGoogleSheet_att_wdx.txt",header=T)
bad_subj<-match(c("11330_20141002","11364_20150317","11454_20151019","11553_20160620","11583_20161209"),subj$MRid)
data_table<-subj[-bad_subj, ]

attach(data_table2)
plot(Cohort,age,
     xlab="Group", ylab="Age",
     main="Age Box Plot")

require(ggplot2)
qplot(Cohort,age,
      xlab="Group", ylab="Age",
      main="Age Scatter Plot")

scatterplot(age ~ Cohort,data=subj, 
            xlab="Group", ylab="Age", 
            main="Age Scatter Plot",
            boxplot=FALSE)