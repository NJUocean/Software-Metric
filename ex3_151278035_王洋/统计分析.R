library(moments)
data=read.csv(choose.files())
metrics=data[,4:9]
sta=data.frame(index=seq(1,10))
for(i in 1:6){
  temp=metrics[,i]
  sta[,i+1]=c(fivenum(temp),mean(temp),skewness(temp)-3,kurtosis(temp),cor(temp,data$bug,method='pearson'),cor(temp,data$bug,method='spearman'))
  print(cor.test(temp,data$bug,method='pearson'))
  print(cor.test(temp,data$bug,method='spearman'))
}
sta=sta[,2:7]
names(sta)=names(metrics)
row.names(sta)=c('Min','1st Qu.','Median','3rd Qu.','Max','Mean','Skewness','Kurtosis','Pearson','Spearman')
write.csv(sta,'static.csv')


