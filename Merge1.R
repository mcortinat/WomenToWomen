## Magdalena Cortina
## Teaching Assistants as Role Models in Economics
####################
## This script merges the raw data into one data base with information about the students, course registration, teachers and TA.

library(data.table)
library(janitor)
library(purrr)
library(foreign)
rm(list = ls())

path      <-getwd()
pathD     <-paste0(path,"/02 Data/")
pathR     <-paste0(path,"/03 Results/")

# Student data (Data alumnos)
alumnos1  <-readRDS(paste0(pathD,"/Datos crudos/DATA ALUMNOS.rds"))
alumnos1  <- clean_names(alumnos1)
alumnos2  <- readRDS(paste0(pathD,"/Datos crudos/estado y tipo postulacion.rds"))
alumnos2  <- clean_names(alumnos2)
alumnos3  <- readRDS(paste0(pathD,"/Datos crudos/datos alumnos missing.rds"))
alumnos3  <- clean_names(alumnos3)
alumnos4  <- readRDS(paste0(pathD,"/Datos crudos/alumnos.rds"))
alumnos4  <- clean_names(alumnos4)

# Course registration data (inscripciones)
insc1     <- readRDS(paste0(pathD,"/Datos crudos/INSCRIPCIONES.rds"))
insc1     <- clean_names(insc1)

insc2     <- readRDS(paste0(pathD,"/Datos crudos/INSCRIPCIONES COMERCIAL 2020.rds"))
insc2     <- clean_names(insc2)

insc3     <- readRDS(paste0(pathD,"/Datos crudos/INSCRIPCIONES 2019-2 COMERCIAL.rds"))
insc3     <- clean_names(insc3)

isnc4     <- readRDS(paste0(pathD,"/Datos crudos/inscripciones.rds")) ## inscripciones 2020/1-2021-1
insc4     <- clean_names(insc4)

# Teaching Assistants data  (ayudantes)
ayud1     <- readRDS(paste0(pathD,"/Datos crudos/AYUDANTES POR SECCION.rds")) 
ayud1     <- clean_names(ayud1)

ayud2     <- readRDS(paste0(pathD,"/Datos crudos/AYUDANTES ENVÍO 2.rds"))
ayud2     <- clean_names(ayud2)

ayud3     <- readRDS(paste0(pathD,"/Datos crudos/AYUDANTES 2019-2.rds"))
ayud3     <- clean_names(ayud3)

ayud4     <- readRDS(paste0(pathD,"/Datos crudos/AYUDANTES ECONOMÍA 2020.rds"))
ayud4     <- clean_names(ayud4)

ayud5     <- readRDS(paste0(pathD,"/Datos crudos/AYUDANTES CON EVALUACIÓN.rds"))
ayud5     <- clean_names(ayud5)

# Teachers data (profesores)
prof1     <- readRDS(paste0(pathD,"/Datos crudos/EV DOCENTE.rds"))
prof1     <- clean_names(prof1)

prof2     <- readRDS(paste0(pathD,"/Datos crudos/GRADOSPROFESORES.rds"))
prof2     <- clean_names(prof2)

prof3     <- readRDS(paste0(pathD,"/Datos crudos/GRADOS PROFESORES 2019-2.RDS"))
prof3     <- clean_names(prof3)

# Transforming everything to data.table
list2env(eapply(.GlobalEnv, function(x) {if(is.data.frame(x)) {setDT(x)} else {x}}), .GlobalEnv)

## Merge student data (alumnos)
    alumnos <- merge(alumnos1,alumnos2, by = "id_alumno")
    setnames(alumnos, "psu_historia", "psu_hist")
    missing_psu <- alumnos3
    rm(alumnos1, alumnos2,alumnos3)

## Merge course registration data
    insc1 <- insc1[,nombre_asignatura:=NULL]
    insc2 <- insc2[,nota:=NA][,nombre_asignatura:=NULL]
    setnames(insc3, "id_profe", "id_profesor")
    setnames(insc3, "jornada_profesor", "jornada")
    insc3[,grado_profesor:=NULL][,nombre_asignatura:=NULL][,nota:=NA]

    inscripciones <- rbind(insc1,insc2,insc3)
    rm(insc1,insc2,insc3)

## Merge TA data (ayudantes)
### ayud5 is the one that contains all of the above.    
### ayud5 es la suma de todas las anteriores. es la final que contiene todo
    ayudantes <- ayud5
    setnames(ayudantes, "id_curso", "id_sec")
    setnames(ayudantes, "genero", "gen_ayud")
    setnames(ayudantes, "nota", "nota_ayud")
    rm(ayud1,ayud2,ayud3,ayud4,ayud5)

## Merge teachers data
grados_prof <- rbind(prof2,prof3)
rm(prof2,prof3)
prof1 <- prof1[,.(id_sec,ev_doc,sigla,id_profesor)]

#######
data1 <- merge(alumnos,inscripciones, by = "id_alumno")
data1 <- as.data.frame(data1)
ayudantes <- as.data.frame(ayudantes)
data2 <- merge(data1,ayudantes, by ="id_sec")
data3 <- merge(data2,prof1, by = c("id_sec","sigla","id_profesor"), all=T)

# Final data
write.dta(data3, "base_uai.dta")
