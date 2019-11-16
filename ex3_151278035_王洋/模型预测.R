rm(list=ls())
library(MASS)#lda qda
library(pROC)
library(caret)
library(class)
library(tree)
library(randomForest)
library(gbm)
library(ROCR)
library(e1071)
library(graph)
library(scmamp)
library(RSNNS)
library(klaR)
library(pls)
rocplot=function(truth,pred,main){
  predob=prediction(pred,truth)
  perf=performance(predob,"tpr","fpr")
  plot(perf,main = main)
}
data=read.csv('c:\\Users\\WANGYANG\\Desktop\\file.csv')
metrics=data[,4:24]
metrics$bug=0
metrics$bug[data$bug>0]=1
K=10
n=10
auc_matrix = matrix(0,nrow = K*K,ncol=n)
size=length(metrics$bug)
learners=c('ols','logistic','lda','qda','knn','c4.5','randomforest','gbm','pcr','naivebayes')
for(i in 1:K){
  folds=createFolds(metrics$bug,k=10)
  for(j in 1:K){
    testindex=folds[[j]]
    testset=metrics[testindex,]
    trainset=metrics[-testindex,]
    #线性回归
    fit1=lm(bug~.,data=trainset)
    predict1=predict(fit1,testset)
    auc_matrix[(i-1)*10+j,1]=auc(testset$bug,predict1)
    #logistic回归
    fit2=glm(bug~.,data=trainset,family = binomial)
    predict2=predict(fit2,testset)
    auc_matrix[(i-1)*10+j,2]=auc(testset$bug,predict2)
    #lda
    fit3=lda(bug~.,data=trainset)
    predict3=predict(fit3,testset)
    auc_matrix[(i-1)*10+j,3]=auc(testset$bug,predict3$posterior[,2])
    #qda
    fit4=qda(bug~.,data=trainset)
    predict4=predict(fit4,testset)
    auc_matrix[(i-1)*10+j,4]=auc(testset$bug,predict4$posterior[,2])
    #knn
    fit5=knn(train = trainset[,-21],test = testset[,-21],cl=trainset[,21],k=7,prob = TRUE)
    prob=attr(fit5,'prob')
    predict5=ifelse(fit5=='1',prob,1-prob)
    auc_matrix[(i-1)*10+j,5]=auc(testset$bug,predict5)
    #决策树
    fit6=tree(bug~.,data = trainset)
    predict6=predict(fit6,testset)
    auc_matrix[(i-1)*10+j,6]=auc(testset$bug,predict6)
    #随机森林
    fit7=randomForest(formula=bug~.,data=trainset,mtry=6,importance=TRUE)
    predict7=predict(fit7,testset)
    auc_matrix[(i-1)*10+j,7]=auc(testset$bug,predict7)
    #gbm
    fit8=gbm(bug~.,data = trainset,distribution='gaussian',n.trees=500)
    predict8=predict(fit8,testset,n.trees = 500)
    auc_matrix[(i-1)*10+j,8]=auc(testset$bug,predict8)
    #pcr
    fit9=pcr(bug~.,data = trainset,scale=TRUE)
    predict9=predict(fit9,testset,ncomp = 12)
    auc_matrix[(i-1)*10+j,9]=auc(testset$bug,predict9)
    #nb
    l=dim(trainset)[1]
    bug=rep('no',l)
    bug[trainset$bug==1]='yes'
    trainset=data.frame(trainset[,1:20],bug)
    fit10 <- NaiveBayes(bug~.,data = trainset)
    predict10=predict(fit10,testset)[[2]][,2]
    auc_matrix[(i-1)*10+j,10]=auc(testset$bug,predict10)
  }
}
colnames(auc_matrix)=learners
write.csv(auc_matrix,"auc_matrix.csv")
plotCD(data.frame(auc_matrix),alpha=0.1)
res <- postHocTest(auc_matrix, test = "friedman", use.rank=TRUE, correct="holland")
drawAlgorithmGraph(res$corrected.pval, res$summary,alpha = 0.5)
heatmap(auc_matrix)


