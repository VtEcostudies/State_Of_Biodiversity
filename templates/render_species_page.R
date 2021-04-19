Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/Rstudio/bin/pandoc");

sppVal <- commandArgs()[7]

orderRequest <- commandArgs()[6]

library(VTatlas)

obs <- VTatlas::queryAPI(query = list(paste0("order:",orderRequest)),
                 fields = c("taxon_name"))

sppAll <- unique(obs)

t_obs <- table(obs)

spp50 <- which(t_obs>=50)

spp <- names(which(t_obs>=50))

for(S in 1:length(spp50)){
rmarkdown::render('MaxEnt_Current_Future_Phenology_Order.Rmd',
                   output_file=paste0(spp[S],".html"),
                   output_dir="MaxEnt_Results",
                   params = list(dynamictitle = spp[S],
                                 species_val = spp[S],
                                 order = orderRequest))
}


