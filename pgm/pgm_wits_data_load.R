# pgm_wits_data_load.R

# packages
library(reshape2)

# Workspace
setwd("/Users/claudegrasland1/Documents/mygit/trade")
list.files(("data"))

# Load data
tab<-read.table(file="data/WITS_trade2009.csv",quote = "",
           header = T, 
           stringsAsFactors = F,
           sep=";",
           dec=".")
head(tab)
tab<-tab[tab$PartnerISO3!="WLD",]
tab<-tab[tab$PartnerISO3!="EUN",]
tab<-tab[tab$ReporterISO3!="EUN",]
tab<-tab[tab$PartnerISO3!="UNS",]
tab<-tab[tab$ReporterISO3!="UNS",]

tabexp<-tab[tab$TradeFlowName=="Export",c("ReporterISO3","PartnerISO3","TradeValue.in.1000.USD")]
head(tabexp)
tabexp<-melt(melt(tabexp))[,c(1,2,5)]
names(tabexp)<-c("i","j","Fij_i")
table(tabexp$j)

tabimp<-tab[tab$TradeFlowName=="Import",c("PartnerISO3","ReporterISO3","TradeValue.in.1000.USD")]
tabimp<-melt(melt(tabimp))[,c(1,2,5)]
names(tabimp)<-c("i","j","Fij_j")

tabref1<-merge(tabexp,tabimp, by=c("i","j"),all.x=T,all.y=T)
head(tabref1)
dim(tabref1)

tabref2<-tabref1
names(tabref2)<-c("j","i","Fji_i","Fji_j")
tabref<-merge(tabref1,tabref2, by=c("i","j"),all.x=T,all.y=T)
head(tabref)


# Choose a rule of decision for Fij

#privilégier l'importateur, puis l'exportateur, puis le flux inverse supposé symétrique ...
tabref$Fij<-tabref$Fij_j
head(tabref)
tabref$Fij[is.na(tabref$Fij)]<-tabref$Fij_i[is.na(tabref$Fij)]
tabref$Fij[is.na(tabref$Fij)]<-tabref$Fji_i[is.na(tabref$Fij)]
tabref$Fij[is.na(tabref$Fij)]<-tabref$Fji_j[is.na(tabref$Fij)]
summary(tabref$Fij)

# tableau final avec cases manquantes (sans total monde)
head(tabref)
tabfin1<-tabref[,c(1,2,7)]
head(tabfin1)


# tableau final complet
mat<-dcast(tabfin1, i~j,sum)
dim(mat)
head(mat)
tabfin2<-melt(mat)
names(tabfin2)<-c("i","j","Fij")
dim(tabfin2)
sqrt(dim(tabfin2))[1]
head(tabfin2)
write.table(tabfin2,"data/WITS_Trade2009_harmonized_flows.csv",quote=FALSE,row.names=FALSE,sep=";", dec=".")



#Check consistency of results
flow<-as.matrix(mat[,-1])
rownames(flow)<-mat[,1]
Oi<-round(apply(flow,1,sum)/1000000,3)
Dj<-round(apply(flow,2,sum)/1000000,3)
x<-data.frame(names(Oi), Oi,Dj)
names(x)<-c("ISO3","EXP","IMP")
x$VOL<-x$EXP+x$IMP
x$SOl<-x$EXP-x$IMP
x$ASY<-x$SOL/x$VOL
x<-x[order(x$VOL,decreasing = T),]
head(x,50)


write.table(x,"data/WITS_Trade2009_harmonized_margins.csv",quote=FALSE,row.names=FALSE,sep=";", dec=".")

