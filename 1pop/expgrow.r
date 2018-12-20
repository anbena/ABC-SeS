#wrapper script to simulate two population split with no gene flow
#Rscript --vanilla ./m1.r <nchr> <locuslength> <nlociXsim> <recrate=1.12e-8> <nsimulations>
args<-commandArgs(trailingOnly=TRUE)
ms<-"/opt/software/genetics/ms/ms"
cpd<-"./"
mod<-"expgrow"
nchr<-as.character(args[1])
tgen<-1
mu<-1.25e-8
recomb<-as.numeric(args[4])
ll<-as.numeric(args[2])#locus length
nsims<-as.numeric(args[5])#number of ABC simulations
nloci<-as.numeric(args[3])#loci to simulate in each sim
out<-paste(mod,"_ll",as.character(ll),"_nl",as.character(nloci),"_r",as.character(recomb),"_nc",nchr,sep="")
#main param
n1<-sample(500:50000,nsims,replace=T)
intensity<-runif(nsims,min=10,max=100)
tg<-sample(100:20000,nsims,replace=T)
#param transformations
tn1<-4*n1*mu*ll
tgs<-(tg/tgen)/(4*n1)
g=-(1/tgs)*log(((n1/intensity)/n1))
srec<-4*n1*(recomb*(ll-1))

partable<-cbind(n1,intensity,tg)
colnames(partable)<-c("n1","intensity","tg")
partablescaled<-cbind(tn1,tgs,g,srec)
write.table(partable,paste(out,".param",sep=""),row.names=F,quote=F,sep="\t")
write.table(partablescaled,paste(out,".paramscaled",sep=""),row.names=F,col.names=T,quote=F,sep="\t")
i<-1
write(paste(ms," ",as.character(nchr)," ",as.character(nloci)," -t ",as.character(tn1[i])," -r ",as.character(srec[i])," ",as.character(ll)," -G ",as.character(g[i])," -eG ",as.character(tgs[i])," 0"," | ",cpd,"compute_pd.py -np 1 -nc ",nchr," -w 100 -b 20 > ",out,".tab",sep=""),stderr())
for (i in 1:nsims){
	print(i)
	if (i==1){
		system(paste(ms," ",as.character(nchr)," ",as.character(nloci)," -t ",as.character(tn1[i])," -r ",as.character(srec[i])," ",as.character(ll)," -G ",as.character(g[i])," -eG ",as.character(tgs[i])," 0"," | ",cpd,"compute_pd.py -np 1 -nc ",nchr," -w 100 -b 20 > ",out,".tab",sep=""))
	}
	else{
		system(paste(ms," ",as.character(nchr)," ",as.character(nloci)," -t ",as.character(tn1[i])," -r ",as.character(srec[i])," ",as.character(ll)," -G ",as.character(g[i])," -eG ",as.character(tgs[i])," 0"," | ",cpd,"compute_pd.py -np 1 -nc ",nchr," -w 100 -b 20 >> ",out,".tab",sep=""))
	}
}
