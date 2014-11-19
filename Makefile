## MAKEFILE
# call like: 
# 
#   make label
#   
# where labels are defined below like:
#
#   label: depends
#        command
#
# `make` by itself defaults to label 'all'


all: glm

glm: preproc behave
	./03_GLM.bash

preproc: fetchData mprage
	./02_preproc.bash

behave: fetchData
	./01_getBehave.bash

mprage: fetchData
	./01_cpMprage.bash

fetchData:
	./00_fetchData.bash
	# writes SubjInfoGoogleSheet.txt by grabbing google sheet
	# copies over new subjects from wallace


dsi: fetchData
	./01_cpDSI.bash
