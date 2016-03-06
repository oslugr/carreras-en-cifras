# Libreria de graficos
library(ggplot2)
rm ( list = ls() )

# Suponemos utf8
trabajando <- read.csv2(  "./listas/INE.csv", 
                          col.names=c("carreras",rep(c("hombres","mujeres"),3)),
                          header = FALSE, 
                          sep=",",
                          dec="."
                        )
                        
graduados <- read.csv2(  "./listas/201415matriculasgradoramas.csv",
                          col.names = c("ramas","carreras","hombres","mujeres","Total"), 
                          header = TRUE, 
                          sep=","
                        )


# Limpiamos un poco el dataset
trabajando <- na.omit( trabajando )



# Number of columns of dataset
n <- ncol(trabajando)

trabajando.titul <- tolower( trabajando$carreras )
graduados.titul <- tolower( graduados$carreras )



# Deja los dos datasets con solo las asignaturas comunes
comunes <- intersect( trabajando.titul, graduados.titul)
trabajando <- trabajando[ which( is.element( 
                                            tolower( trabajando$carreras ),
                                            comunes 
                                            )
                                )
                        , ]
graduados <- graduados[ which( is.element( 
                                          tolower( graduados$carreras ), 
                                          comunes 
                                          ) 
                               ) 
                        , ]
trabajando <- trabajando[ order( trabajando$carreras ), ]
graduados <- graduados[ order( graduados$carreras ), ]


data <- data.frame( comunes, trabajando$hombres/trabajando$mujeres, graduados$hombres/graduados$mujeres )
colnames(data) <- c("titulacion", "h/m.trabajando", "h/m.graduados" )
