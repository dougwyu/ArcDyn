# THIS SCRIPT PERFORMS THE ANALYSIS OF MOCK COMMUNITIES IN STEP 5.
# THE OUTPUT OF THIS SCRIPTSIS ARE STATISTICAL MODELS THAT CONVERT THE PREDICTORS INTO SPECIES OCCURRENCES AND ABUNDANCES

# SET DIRECTORIES AND LOAD DATA (START) #####################################
#setwd() set your working directory
localDir = "."
dataDir = file.path(localDir, "Rdata")
# load(file.path(dataDir, "input_data_step5_20190115.RData")) # 308 mitogenomes, minimap2 v 2.10, version used for SPIKEPIPE paper
# load(file.path(dataDir, "input_data_step5_20190202.RData")) # 349 MITOCOICYTB, minimap2 v 2.10
load(file.path(dataDir, "input_data_step5_20190204.RData")) # 349 MITOCOICYTB, minimap2 v 2.15
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

# SELECT DATA (START) #####################################
type = c("COI","mitogenome")[2]
# above, set the number to 1 or 2 according to whether you wish to run the barcode or mitogenome analyses
if(type=="mitogenome"){
  mock_data = mock_data_mitogenome
  PC0 = 0.1 #the percentage cover threshold is determined by preliminary analyses of the data, see below
} else {
  mock_data = mock_data_COI
  PC0 = 0.5
}
# SELECT END (START) #####################################

# CONSTRUCT FSL (START) ################################################
samples = unique(mock_design$sample)
mock_data$spike = rep(0,dim(mock_data)[1])
mock_data$mapped_reads_proportion = rep(0,dim(mock_data)[1])
for (sa in samples){
  sel = mock_data$sample == sa
  sel.mock_data = mock_data[sel,]
  spike = c(sel.mock_data[sel.mock_data$sp == "spike1",]$mapped_reads,
            sel.mock_data[sel.mock_data$sp == "spike2",]$mapped_reads,
            sel.mock_data[sel.mock_data$sp == "spike3",]$mapped_reads)
  sel2 = mock_design$sample == sa
  sel.mock_design = mock_design[sel2,]
  input = c(sel.mock_design[sel.mock_design$input_sp == "spike1",]$input_amount,
            sel.mock_design[sel.mock_design$input_sp == "spike2",]$input_amount,
            sel.mock_design[sel.mock_design$input_sp == "spike3",]$input_amount)
  mock_data$spike[sel] = mean(spike/input)
  mock_data$mapped_reads_proportion[sel] = mock_data$mapped_reads[sel]/(mock_seq_depth$mitogenome_seqs[mock_seq_depth$sample==sa])
}
mock_data$FSL = log(mock_data$mapped_reads/mock_data$spike)
# CONSTRUCT FSL (END) ################################################

# CONSTRUCT TRUE ABUNDANCE (START) ################################################
mock_data$Y = rep(0,dim(mock_data)[1])
for (sa in samples){
  sel2 = mock_design$sample == sa
  seldat = mock_design[sel2,]
  for (i in 1:dim(seldat)[1]){
    mock_data$Y[mock_data$sample==sa & mock_data$sp==seldat$input_sp[i]] = seldat$input_amount[i]
  }
}
# CONSTRUCT TRUE ABUNDANCE (END) ################################################

# MAKE DATAFRAME THAT INCLUDES PREDICTORS AND RESPONSES (START) ################################################
da = data.frame(SP = mock_data$sp,
                RUN = mock_data$plate,
                PC = mock_data$PC,
                FSL = mock_data$FSL,
                FTL = log(mock_data$mapped_reads_proportion),
                Y = mock_data$Y,
                PA = sign(mock_data$Y))
da = da[(!(da$SP=="spike1" | da$SP=="spike2" | da$SP=="spike3")),]
# MAKE DATAFRAME THAT INCLUDES PREDICTORS AND RESPONSES (END) ################################################

# PRINT THE NUMBERS OF TRUE AND FALSE PRESENCES AND ABSENCES (START) ################################################
print(c(sum(da$Y>0),sum(da$Y==0)))
print(c(sum(da$PC[da$Y>0]>0),sum(da$PC[da$Y==0]>0)))
# the percentage cover thresholds set in the beginning of the script are based on plotting species occurrence against percentage cover
sel=da$PC>PC0
print(c(sum(da[sel,]$Y>0),sum(da[sel,]$Y==0)))
print(c(sum(da[!sel,]$Y>0),sum(da[!sel,]$Y==0)))
# PRINT THE NUMBERS OF TRUE AND FALSE PRESENCES AND ABSENCES (END) ################################################

# FILTER THE DATA BY PERCENTAGE COVER THRESHOLD (START) ################################################
da1 = da[da$PC>PC0,]
# FILTER THE DATA BY PERCENTAGE COVER THRESHOLD (END) ################################################

# FIT ALTERNATIVE ABUNDANCE MODELS (START) ################################################
da1$logY = log(da1$Y)
plot(da1$FSL,da1$logY)
mylm1 = lm(logY ~ FSL + PC + RUN + SP, data = da1)
mylm2 = lm(logY ~ FSL + RUN + SP, data = da1)
mylm3 = lm(logY ~ FTL + RUN + SP, data = da1)
mylm4 = lm(logY ~ FSL + SP, data = da1)
mylm5 = lm(logY ~ FSL + RUN, data = da1)
my_aic=AIC(mylm1,mylm2,mylm3,mylm4,mylm5)
print(my_aic$AIC-min(my_aic$AIC))
print(c(summary(mylm1)$r.squared,
        summary(mylm2)$r.squared,
        summary(mylm3)$r.squared,
        summary(mylm4)$r.squared,
        summary(mylm5)$r.squared))

mylm = mylm2
coef = mylm$coefficients
print(coef[2])
# FIT ALTERNATIVE ABUNDANCE MODELS (END) ################################################

# TEST IF SPECIES EFFECTS ARE CORRELATED WITH MITOGENOME LENGTH (START) ################################################
sp.in.model = unique(da1$SP)
sp.effect = rep(0,length(sp.in.model))
mt.length = rep(0,length(sp.in.model))
for (i in 1:length(sp.in.model)){
  sel=names(coef)==paste0("SP",sp.in.model[i])
  if(sum(sel)==1){
    sp.effect[i]=coef[sel]
  }
  if(type=="mitogenome"){
    mt.length[i] = log(species$mt_length[species$sp==as.character(sp.in.model[i])])
  } else {
    mt.length[i] = log(species$COI_length[species$sp==as.character(sp.in.model[i])])
  }
}
summary(lm(sp.effect ~ mt.length))
# TEST IF SPECIES EFFECTS ARE CORRELATED WITH MITOGENOME LENGTH (END) ################################################

# generate the original SPIKEPIPE figure using data_grid, add_predictions, and ggplot
library(modelr)
library(tidyverse)

# da1 <- filter(da1, SP != "sp7") # drop Pardosa because there are only three points
da1$SP <- fct_drop(da1$SP) # drop the non-mock species from the levels
da1$SP %>% unique() # should only have 19 levels
da1 <- da1 %>% left_join(species, by = c("SP" = "sp")) %>% 
    select(-BOLD, -mitogenome, -COI, -mt_length, -COI_length, -omit_from_env) %>% 
    unite("family_genus_speciesBOLD", c("Family", "Genus", "Species_BOLD")) %>% 
    mutate_at("family_genus_speciesBOLD", str_remove, "_BOLD:[\\w]+") %>% 
    rename(family_genus_species = family_genus_speciesBOLD)
    
summary(mylm) # confirm this is optimal model:  logY ~ FSL + RUN + SP, data = da1

theme <- theme_bw() + theme(plot.background = element_blank(),
                            panel.grid.minor = element_blank(),
                            panel.grid.major = element_blank(),
                            axis.line = element_line(color = 'black'),
                            legend.position="bottom",
                            legend.text = element_text(size = 7))

da1 <- da1 %>% 
    add_predictions(mylm, var = "predlogY")

ggplot(data = da1, aes(x = FSL, y = logY, colour = family_genus_species)) +
    geom_point(alpha = 1, size = 2) +
    geom_line(aes(y = predlogY)) +
    theme +
    facet_wrap(~ RUN) +
    labs(colour = NULL, x = "Focal versus Standard and Lysis:  ln(FSL)", y = "Raw abundance:  ln(ng_DNA)") +
    geom_abline(intercept = 6, slope = 1, size = 1, linetype = 2)
# to do
# replace y-axis values with back-transformed 'ng DNA' values (and log the axis)
# adjust axis labels to give units and indicate that the axes are logged
# label species names for the furthest left and right lines (maybe remove legend?) 
# what is going on with the furthest left species (green dots, Spilogona megastoma or micans?)
# decide whether to keep sp177 (Pardosa) in the figure



# if i don't want to use different colors for the species and simply have multiple lines, one for each species, i use 'group = family_genus_species' in the mapping
ggplot(data = da1, aes(x = FSL, y = logY, group = family_genus_species)) +
    geom_point(alpha = 1, size = 2) +
    geom_line(aes(y = predlogY)) +
    theme +
    facet_wrap(~ RUN) +
    labs(colour = NULL, x = "Focal versus Standard and Lysis (FSL)", y = "Raw abundance") +
    geom_abline(intercept = 6, slope = 1, size = 1, linetype = 2)

# if i want to create a data grid, but it's not necessary, and it creates fitted lines that span the full range of FSL
# grid <- da1 %>% 
#     data_grid(RUN, SP, FSL = seq_range(FSL, n = 20)) %>% 
#     add_predictions(mylm, var = "logY") %>% 
#     mutate(Y = exp(logY))

# min(da1$logY)
# max(da1$logY)

