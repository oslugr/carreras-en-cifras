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


# Deja los dos datasets con solo las asignaturas comunes
trabajando.titul <- trabajando$carreras 
graduados.titul <- graduados$carreras
comunes <- intersect( trabajando.titul, graduados.titul)


tol <- 3.0

gradpair <- function(x){  d<- stringdist(tolower(x), tolower(graduados.titul), method='lv')
                          argmin <- which.min (d)
                          
                          if (d[argmin]<=tol){ 
                              list(x, graduados.titul[argmin])
                          }
}

v <- lapply (trabajando.titul, gradpair)
v <- v[! unlist(lapply(v, is.null))]
v <- unlist(v)


trabajando <- trabajando[ is.element( trabajando$carreras, v ), ]
graduados <- graduados[ is.element( graduados$carreras, v ), ]
trabajando <- trabajando[ order( trabajando$carreras ), ]
graduados <- graduados[ order( graduados$carreras ), ]


# data frame para representar ratios
data <- data.frame( comunes, 
                    as.numeric(trabajando$hombres) / as.numeric(trabajando$mujeres), 
                    as.numeric(graduados$hombres) / as.numeric(graduados$mujeres )
                  )
colnames(data) <- c("titulacion", "ratio.trabajando", "ratio.graduados" )


graph <-  ggplot(data,aes( x=ratio.graduados,y=ratio.trabajando, colour=titulacion, size=8) ) + 
          xlab("Ratio hombres/mujeres graduados") +
          ylab("Ratio hombres/mujeres trabajando") +
          theme(legend.position="none")+
          geom_point()+
          geom_abline(intercept=0, slope=1, colour="grey",size=1.2, linetype=2)
          
graph
ggsave(filename="ratios.png", plot=graph, scale=0.8)