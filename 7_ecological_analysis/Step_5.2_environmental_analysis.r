# THIS SCRIPT PERFORMS THEANALYSIS OF ENVIRONMENTAL SAMPLES IN STEP 5.
# THE OUTPUT OF THIS SCRIPT ARE SPECIES OCCURRENCES AND ABUNDANCES FOR ENVIRONMENTAL DATA,
# AS WELL AS THE ECOLOGICAL ANALYSES THAT RESULT IN FIGURES 1 AND 2 OF THE PAPER

# SET DIRECTORIES AND LOAD DATA (START) #####################################
#setwd() set your working directory
localDir = "."
dataDir = file.path(localDir, "Rdata")
# load(file.path(dataDir, "input_data_step5_20190115.RData"))
# load(file.path(dataDir, "input_data_step5_20190202.RData"))
load(file.path(dataDir, "input_data_step5_20190204.RData"))
#input_data_step5.RData includes the following data frames:
#species: the species included in the study
#spikes: the spikes used
#mock_design: the study desing for the mock analysis
#mock_seq_depth: sequencing depth for the mock analysis
#mock_data_COI: mock data for the barcoding approach
#mock_data_mitogenome: mock data for the mitogenome approach
#env_design: the study design for the environmental analysis
#env_seq_depth: sequencing depth for the environmental analysis
#env_data_COI: environmental data for the barcoding approach
#env_data_mitogenome: environmental data for the mitogenome approach
# SET DIRECTORIES AND LOAD DATA (END) #####################################

# DEFINE THE PDF-FILE WHERE THE 2x3 PANEL FIGURE 1 WILL BE STORED (START) #####################################
# pdf("Figure 1.pdf",width=9,height=6,paper='special')
par(mfrow=c(2,3))
# DEFINE THE PDF-FILE WHERE THE 2x3 PANEL FIGURE 1 WILL BE STORED (END) #####################################

for(COImito in 1:2){ #Loop over the two types of analyses: barcode and mitogenome

  # SELECT DATA AND STATISTICAL MODELS (START) #####################################
  type = c("COI","mitogenome")[COImito]
  if(type=="mitogenome"){
    env_data = env_data_mitogenome
    PC0 = 0.1 #This parameter is based on script 5.1
    BETA_FSL = 0.9035603 #This parameter is based on script 5.1
  } else {
    env_data = env_data_COI
    PC0 = 0.5 #This parameter is based on script 5.1
    BETA_FSL = 0.8969635 #This parameter is based on script 5.1
  }
  # SELECT DATA AND STATISTICAL MODELS (END) #####################################
  
  # COMPUTE PREDICTORS FOR EACH SAMPLE (START) #####################################
  samples = env_design$sample
  if(type=="mitogenome"){
    spp = species$sp[!is.na(species$mitogenome)]
  } else {
    spp = species$sp
  }
  ny = length(samples)
  ns = length(spp)
  PC = matrix(0,nrow=ny,ncol=ns)
  FSL = matrix(NA,nrow=ny,ncol=ns)
  
  for(i in 1:length(samples)){
    sa = samples[i]
    l_data = env_data[env_data$sample==sa,]
    l_env_design = env_design[env_design$sample==sa,]
    input = c(l_env_design$spike1,l_env_design$spike2,l_env_design$spike3)
    lysis = l_env_design$lysis_buffer_proportion
    spike_reads = c(l_data$mapped_reads[l_data$sp=="spike1"],
                    l_data$mapped_reads[l_data$sp=="spike2"],
                    l_data$mapped_reads[l_data$sp=="spike3"])
    spike = mean(spike_reads/input)
    
    for(j in 1:ns){
      sp = spp[j]
      sel = which(l_data$sp==sp)
      if(length(sel)>0){
        ll_data = l_data[sel,]
        if (!is.na(ll_data$PC)){
          PC[i,j] = ll_data$PC
        }
        
        if(PC[i,j]>0.1){
          FSL[i,j] = log(ll_data$mapped_reads/(lysis*spike))
        }
      }
    }
  }
  # COMPUTE PREDICTORS FOR EACH SAMPLE (END) #####################################
  
  # PREDICT SPECIES OCCURENCES (START) #####################################
  Y = 1*(PC>PC0)
  # PREDICT SPECIES OCCURENCES (END) #####################################

  # PREDICT SPECIES ABUNDANCES (START) #####################################
  YABU = BETA_FSL*FSL
  # PREDICT SPECIES ABUNDANCES (END) #####################################
  
  # MAKE A DATAFRAME THAT INCLUDES THE ENVIRONMENTAL SAMPLES FOR TRAP-DATE COMBINATIONS (START) #####################################
  TD = data.frame(trap = env_design$trap, date = env_design$date)
  TD = unique(TD)
  nTD = dim(TD)[1]
  index = rep(NA,ny)
  for (i in 1:nTD){
    sel = which(env_design$trap == TD$trap[i] & env_design$date == TD$date[i])
    index[sel] = i
  }
  Y1 = NULL
  Y2 = NULL
  Y1run = NULL
  Y2run = NULL
  YABU1 = NULL
  YABU2 = NULL
  YABU1run = NULL
  YABU2run = NULL
  for (zzz in 1:nTD){
    repls = which(index==zzz)
    if(length(repls)>1){
      for (i in 1:(length(repls)-1)){
        for (j in (i+1):length(repls)){
          repl1 = repls[1]
          repl2 = repls[2]
          Y1 = append(Y1,Y[repl1,])
          Y2 = append(Y2,Y[repl2,])
          Y1run = append(Y1run, rep(env_design$run[repl1],ny))
          Y2run = append(Y2run, rep(env_design$run[repl2],ny))
          sel = which(Y[repl1,]==1 & Y[repl2,]==1)
          YABU1 = append(YABU1,YABU[repl1,sel])
          YABU2 = append(YABU2,YABU[repl2,sel])
          YABU1run = append(YABU1run, rep(env_design$run[repl1],length(sel)))
          YABU2run = append(YABU2run, rep(env_design$run[repl2],length(sel)))
        }
      }
    }
  }
  # MAKE A DATAFRAME THAT INCLUDES THE ENVIRONEMNTAL SAMPLES FOR TRAP-DATE COMBINATIONS (END) #####################################
  
  # CHECK CONSISTENCY OF SPECIES OCCURRENCES FOR REPLICATE SAMPLES (START) #####################################
  print(c(length(Y1),sum(Y1+Y2==0),sum(Y1+Y2==2),sum(Y1+Y2==1)))
  # CHECK CONSISTENCY OF SPECIES OCCURRENCES FOR REPLICATE SAMPLES (END) #####################################
  
  # CHECK CONSISTENCY OF SPECIES ABUNDANCES FOR REPLICATE SAMPLES AND STANDARDIZE AMONG RUNS (START) #####################################
  summary(lm(YABU2~YABU1))
  runs = unique(env_design$run)
  nruns = length(runs)
  nA = length(YABU1)
  for (i in 1:nA){
    YABU1run[i] = which(runs == YABU1run[i])
    YABU2run[i] = which(runs == YABU2run[i])
  }
  YABU1run = as.numeric(YABU1run)
  YABU2run = as.numeric(YABU2run)
  YABUruns = cbind(YABU1run,YABU2run)
  print(unique(YABUruns))
  X = matrix(0,nrow = nA, ncol = 3) #cols: 1->2; 1->3; 1->4
  for (i in 1:nA){
    if(sum(YABUruns[i,]==c(1,2))==2){X[i,1] = -1}
    if(sum(YABUruns[i,]==c(1,3))==2){X[i,2] = -1}
    if(sum(YABUruns[i,]==c(1,4))==2){X[i,3] = -1}
    if(sum(YABUruns[i,]==c(2,3))==2){
      X[i,1] = 1
      X[i,2] = -1}
    if(sum(YABUruns[i,]==c(3,4))==2){
      X[i,2] = 1
      X[i,3] = -1}
  }
  mylm = lm(YABU2~0 + X[,1] + X[,2] + X[,3], offset = YABU1)
  print(summary(mylm))
  coef=mylm$coefficients
  beta = coef[1:3]
  YABU1c = YABU1 + (YABU1run==2)*beta[1] + (YABU1run==3)*beta[2] + (YABU1run==4)*beta[3]
  YABU2c = YABU2 + (YABU2run==2)*beta[1] + (YABU2run==3)*beta[2] + (YABU2run==4)*beta[3]
  summary(lm(YABU1c~0,offset = YABU2c))
  plot(YABU1c,YABU2c,xlab="Abundance (replicate 1)",ylab="Abundance (replicate 2)")
  abline(0,1)
  text(c("A","D")[COImito],x=c(-6.7,-6)[COImito],y=c(1.7,4)[COImito])
  c(sqrt(mean((YABU2-YABU1)^2)),sqrt(mean((YABU2c-YABU1c)^2)))
  # CHECK CONSISTENCY OF SPECIES ABUNDANCES FOR REPLICATE SAMPLES AND STANDARDIZE AMONG RUNS (END) #####################################
  
  # POOL REPLICATE SAMPLES TO CREATE THE DATA MATRIX FOR ECOLOGICAL ANALYSES (START) #####################################
  YY = matrix(0,nrow = nTD, ncol = ns)
  YYABU = matrix(NA,nrow = nTD, ncol = ns)
  for (i in 1:nTD){
    sel = which(env_design$trap == TD$trap[i] & env_design$date == TD$date[i])
    if(length(sel)==1){
      YY[i,] = Y[sel,]
      YYABU[i,] = YABU[sel,]
    } else{
      YY[i,] = 1*(colSums(Y[sel,])>0)
      YYABU[i,] = colMeans(YABU[sel,],na.rm = TRUE)
    }
  }
  
  #omit species not systematically sampled
  keep = rep(NA,ns)
  for(i in 1:ns){
    keep[i] = species$omit_from_env[which(species$sp==spp[i])]=="Keep"
  }
  YY=YY[,keep]
  YYABU=YYABU[,keep]
  
  #omit species too rare for analysis
  print(c(sum(colSums(YY)>0),sum(colSums(YY)>4)))
  selsp = which(colSums(YY)>4)
  YYALL = YY
  YY = YY[,selsp]
  YYABU = YYABU[,selsp]
  # POOL REPLICATE SAMPLES TO CREATE THE DATA MATRIX FOR ECOLOGICAL ANALYSES (END) #####################################
  
  # CONSTRUCT PREDICTORS (YEAR AND JULIAN DATE) FOR THE ENVIRONMENTAL SAMPLES (START) #####################################
  YEAR = rep(0,nTD)
  JDATE = rep(0,nTD)
  for (i in 1:nTD){
    date = TD$date[i]
    year_string = substr(date,start=1,stop=4)
    date0 = as.Date(paste0(year_string,"-01-01"))
    JDATE[i] = julian(date)-julian(date0)
    YEAR[i] = as.numeric(year_string)
  }
  TRAP = TD$trap
  JDATE2 = JDATE*JDATE
  # CONSTRUCT PREDICTORS (YEAR AND JULIAN DATE) FOR THE ENVIRONMENTAL SAMPLES (END) #####################################
  
  # FIT ALTERNATIVE MODELS AND PLOT PANELS BCEF OF FIGURE 1 (START) #####################################
  YEARS = unique(YEAR)
  SY = rep(0,length(YEARS))
  for(i in 1:length(YEARS)){
    SY[i] =  sum(colSums(YYALL[YEAR==YEARS[i],])>0)
  }
  if(type=="mitogenome"){
    SY_mitogenome = SY
  } else{
    SY_COI = SY
  }
  print(summary(glm(SY~YEARS, family = poisson)))
  print(mean(SY))
  
  S = rowSums(YY)
  myglm1 = glm(S ~ YEAR+JDATE+JDATE*YEAR+JDATE2+TRAP, family = poisson)
  myglm2 = glm(S ~ YEAR+JDATE+JDATE*YEAR+JDATE2, family = poisson)
  myglm3 = glm(S ~ YEAR+JDATE+JDATE*YEAR, family = poisson)
  myglm4 = glm(S ~ YEAR+JDATE+JDATE2, family = poisson)
  myglm5 = glm(S ~ YEAR+JDATE, family = poisson)
  myglm6 = glm(S ~ JDATE+JDATE2, family = poisson)
  aic = AIC(myglm1,myglm2,myglm3,myglm4,myglm5,myglm6)
  print(aic-min(aic$AIC))
  if(type=="mitogenome"){
    myglm = myglm2
  }else{
    myglm = myglm4
  }
  summary(myglm)
  for (zzz in 1:2){
    predjdate = min(JDATE):max(JDATE)
    npred = length(predjdate)
    if(zzz==1){predyear = rep(min(YEAR),npred)} else {predyear = rep(max(YEAR),npred)}
    predtrap = rep(TRAP[1],npred)
    preddata = data.frame(YEAR = predyear, JDATE = predjdate, JDATE2 = predjdate^2, TRAP = predtrap)
    if (zzz==1){
      plot(predjdate,exp(predict(myglm,newdata = preddata)),'l',col='black',
                     ylim=c(0,11), xlab = "Julian date", ylab = "Species richness")
        }
    if (zzz==2){
      lines(predjdate,exp(predict(myglm,newdata = preddata)),'l',col='red')
    }
    text("year = 1997",x=180,y=c(8.2,10.7)[COImito],col="black",pos=4)
    text("year = 2013",x=180,y=c(3.5,4)[COImito],col="red",pos=4)
    text(c("B","E")[COImito],x=160,y=10.5)
  }
  
  YYABU = scale(YYABU)
  ABU = rowMeans(YYABU, na.rm=TRUE)
  mylm1 = lm(ABU ~ YEAR+JDATE+JDATE*YEAR+JDATE2+TRAP)
  mylm2 = lm(ABU ~ YEAR+JDATE+JDATE*YEAR+JDATE2)
  mylm3 = lm(ABU ~ YEAR+JDATE+JDATE*YEAR)
  mylm4 = lm(ABU ~ YEAR+JDATE+JDATE2)
  mylm5 = lm(ABU ~ YEAR+JDATE)
  mylm6 = lm(ABU ~ YEAR)
  aic=AIC(mylm1,mylm2,mylm3,mylm4,mylm5,mylm6)
  print(aic-min(aic$AIC))
  if(type=="mitogenome"){
    mylm = mylm5
  }else{
    mylm = mylm6
  }
  summary(mylm)
  for (zzz in 1:2){
    predjdate = min(JDATE):max(JDATE)
    npred = length(predjdate)
    if(zzz==1){predyear = rep(min(YEAR),npred)} else {predyear = rep(max(YEAR),npred)}
    predtrap = rep(TRAP[1],npred)
    preddata = data.frame(YEAR = predyear, JDATE = predjdate, JDATE2 = predjdate^2, TRAP = predtrap)
    if (zzz==1){plot(predjdate,predict(mylm,newdata = preddata),'l',col='black',
                     ylim = c(-0.6,0.6), xlab = "Julian date", ylab = "Mean abundance")}
    if (zzz==2){lines(predjdate,predict(mylm,newdata = preddata),'l',col='red')}
    # FIT ALTERNATIVE MODELS AND PLOT PANELS BCEF OF FIGURE 1 (START) #####################################
  }
  text("year = 1997",x=180,y=c(-0.3,-0.4)[COImito],col="black",pos=4)
  text("year = 2013",x=180,y=c(0.2,0.3)[COImito],col="red",pos=4)
  text(c("C","F")[COImito],x=160,y=0.55)
}
mtext("based on barcode data", side=3, line=-2.3, outer=TRUE)
mtext("based on mitogenome data", side=3, line=-25.5, outer=TRUE)
# dev.off()

# PLOT FIGURE 2 (START) #####################################
# pdf("Figure 2.pdf",width=6,height=6,paper='special')
par(mfrow=c(1,1))
plot(YEARS,SY_mitogenome,col='red',type = 'p',pch = 16,ylim=c(0,80),ylab = "Species richness", xlab = "Year")
points(YEARS,SY_COI,col="black",type = 'p',pch = 16)
points(2004.8,20,col="red",type = 'p',pch = 16)
points(2004.8,15,col="black",type = 'p',pch = 16)
text("based on mitogenome data",x=2005,y=20,col="red",pos=4)
text("based on barcode data",x=2005,y=15,col="black",pos=4)
# dev.off()
mean(SY_mitogenome)
mean(SY_COI)
# PLOT FIGURE 2 (END) #####################################
