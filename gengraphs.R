# Libreria de graficos
library(ggplot2)
# Librería para hacer la distancia entre dos strings
library(stringdist)


# Limpiamos el entorno
rm ( list = ls() )

# Suponemos utf8
trabajando <- read.csv2(  "./listas/INE.csv", 
                          col.names=c("carreras",rep(c("hombres","mujeres"),3)),
                          header = TRUE, 
                          sep=",",
                          dec=".",
                          skip=1,
                          stringsAsFactors = FALSE
                        )               

graduados <- read.csv2(  "./listas/201415matriculasgradoramas.csv",
                          col.names = c("ramas","carreras","hombres","mujeres","Total"), 
                          header = TRUE, 
                          sep=",",
                          stringsAsFactors = FALSE
                        )

# Limpiamos un poco los datasets
trabajando <- na.omit( trabajando )
graduados <- na.omit( graduados )
trabajando <- trabajando[ !duplicated( trabajando$carreras ), ]
graduados <- graduados[ !duplicated( graduados$carreras ), ]


# Extraemos las titulaciones
trabajando.titul <- trabajando$carreras 
graduados.titul <- graduados$carreras


# Tolerancia de la distancia de Levenshtein
tol <- 3.0


# Función que genera pares de carreras comunes a ambos datasets
gradpair <- function(x){  d<- stringdist(tolower(trabajando.titul[x]), tolower(graduados.titul), method='lv')
                          argmin <- which.min (d)
                          
                          if (d[argmin]<=tol){ 
                              list(x, argmin)
                          }
}


# Calculamos las carreras comunes a ambos datasets y los reordenamos
v <- lapply (seq(1,length(trabajando.titul)), gradpair)
tr <- unlist(lapply(v, function(x){ x[1] } ))
gr <- unlist(lapply(v, function(x){ x[2] } ))


trabajando <- trabajando[ tr, ]
graduados <- graduados[ gr, ]
trabajando <- trabajando[ order( trabajando$carreras ), ]
graduados <- graduados[ order( graduados$carreras ), ]


# data frame para representar ratios
data <- data.frame( graduados$carreras, 
                    as.numeric(trabajando$hombres) / as.numeric(trabajando$mujeres), 
                    as.numeric(graduados$hombres) / as.numeric(graduados$mujeres )
                  )
colnames(data) <- c("titulacion", "ratio.trabajando", "ratio.graduados" )

# quitamos valores que no aportan información
data <- data [ data$ratio.graduados > 0, ]


# generamos el gráfico de datos
graph <-  ggplot(data,aes( x=ratio.graduados,y=ratio.trabajando, colour=titulacion, size=8) ) + 
          xlab("Ratio hombres/mujeres graduados") +
          ylab("Ratio hombres/mujeres trabajando") +
          theme(legend.position="none")+
          geom_point()+
          geom_abline(intercept=0, slope=1, colour="grey",size=1.2, linetype=2)
          
graph
ggsave(filename="ratios.png", plot=graph, scale=0.8)


# Calculamos la desviación estándar
data.sd <- sd (with(data, ratio.trabajando / ratio.graduados))
data.mean <- mean(with(data, ratio.trabajando / ratio.graduados))

# Carreras donde hay preferencia en la contratación por hombres
fav.hombres <- data$titulacion[ with(data, abs(ratio.trabajando/ratio.graduados - data.mean) > data.sd  
                                     & ratio.trabajando/ratio.graduados > 1) ]
# Carreras donde hay preferencia en la contratación por mujeres
fav.mujeres <- data$titulacion[ with(data, abs(ratio.trabajando/ratio.graduados - data.mean) > data.sd  
                                     & ratio.trabajando/ratio.graduados < 1) ]
