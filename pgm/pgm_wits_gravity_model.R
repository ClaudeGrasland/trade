# ########################################
# pgm_wits_gravity_model
#
#  Calibration of gravity model on trade flows derived from WITS
#
# (c) Grasland C. (2016)
#
# #######################################

########################################
### A. Prepare workspace ###############
########################################


## A.1 Clear workspace
rm(list=ls())

## A.2 load packages
library(reshape2)

## A.3 Choose main directory & subdirectories
setwd("/Users/claudegrasland1/Documents/mygit/trade")
list.files(("data"))


#######################################
### B. Prepare Data ###################
#######################################


## B.1 Load Trade flows 

tab1<-read.table(file="data/WITS_Trade2009_harmonized_flows.csv",quote = "",
                header = T, 
                stringsAsFactors = F,
                sep=";",
                dec=".")
head(tab1)
tab2<-tab1
names(tab2)<-c("j","i","Fji")
tabflow<-merge(tab1,tab2,by=c("i","j"),all.X=T,all.Y=T)

head(tabflow)

# B.2 Add Size variables
size<-read.table("data/size2009_unep.csv",
                 header = TRUE, 
                 sep = ";",
                 dec=".",
                 stringsAsFactors=FALSE,
                 encoding="UTF-8")
head(size)

sizei<-size[,c(1,2,3,4)]
names(sizei)<-c("i","SUPi","POPi","GDPi")
tabflow<-merge(tabflow,sizei,by=c("i"),all.X=T,all.Y=T)
sizej<-size[,c(1,2,3,4)]
names(sizej)<-c("j","SUPj","POPj","GDPj")
tabflow<-merge(tabflow,sizej,by=c("j"),all.X=T,all.Y=T)




# B.3 Add Proximity variables
geo<-read.table("data/dist_cepii.csv",
                header = TRUE, 
                sep = ";",
                dec=".",
                stringsAsFactors=FALSE,
                encoding="UTF-8")
head(geo)
geo<-geo[,c(1,2,3,5,9,12)]
names(geo)<-c("i","j","CONTij","LANGij","COLOij","DISTij")
tabflow<-merge(tabflow,geo,by=c("i","j"),all.X=T,all.Y=F)

head(tabflow)


# #################################
# ######### (C) GRAVITY MODELS ##
# ################################

# C.0 : Adjustement of data

tab<-tabflow[tabflow$i!=tabflow$j,]
tab$INTij<-tab$Fij+tab$Fji


# (C.1) Choose model 


# Double constraint

mod<-glm(INTij~log(GDPi)+
             log(GDPj)+
             log(DISTij)+
             CONTij +
             LANGij +
             COLOij
         ,
         data=tab,
         family=poisson)


expl<- round(100*(1-(mod$deviance/mod$null.deviance)),2)
print(paste("Deviance explained :",expl,"%"))


summary(mod)

# Resiudals
tab$INTij_estim<-mod$fitted.values
tab$INTij_resraw<-round(tab$INTij-tab$INTij_estim,0)
tab$INTij_resrel<-round(tab$INTij/tab$INTij_estim,2)
tab$INTij_estim<-round(tab$INTij_estim,0)

tab<-tab[order(tab$INTij_resraw),]
head(tab)
head(tab,30)
tail(tab,30)

# Exportation 
write.table(tab,"data/WITS_Trade_2009_gravity_model.csv",quote=FALSE,row.names=FALSE,sep=";", dec=".")
