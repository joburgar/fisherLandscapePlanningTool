# Copyright 2021 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#===========================================================================================#
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#===========================================================================================#

# Fisher Landscape Planning Tool

## Overview  

# This document outlines the usage of the modules in the project Fisher Landscape Planning Tool, which the main module is the Fisher Landscape Explorer (FLEX) tool (located in the modules' folder as a submodule to this project).

## Checking directory
source("R/checkDirectory.R")
checkDirectory()

## Install and load required packages
source("R/installAndLoadPkgs.R")
installAndLoadPkgs()

## Checking modules
# To properly run this model, please make sure all submodules of interest have also been downloaded and, if using GitHub,  initialized (to check if a module has been initialized, please go to the module's folder and check for existing files. If no files can be found, please run the following command).  
source("R/checkingModules.R")
checkingModules(updateSubmodules = TRUE, # Should the submodules be updated?
                whichSubmodules = "FLEX", # Specify which modules to be added
                hostLink = "git@github.com:bcgov/FLEX.git" # Specify the github (SSH) paths to the modules
)

## Setting up paths
setPaths(cachePath = checkPath(file.path(getwd(), "cache"), create = TRUE),
         inputPath = checkPath(file.path(getwd(), "inputs"), create = TRUE),
         outputPath = checkPath(file.path(getwd(), "outputs"), create = TRUE),
         modulePath = checkPath(file.path(getwd(), "modules"), create = TRUE),
         rasterPath = checkPath(file.path(getwd(), "tempDir"), create = TRUE))

## Setting up simulation time 
## NOTE: Currently, the functions are looping on their own over years. 
## Some work is needed to desconstruct the FEMALE_IBM_simulation_same_world() 
## to use the scheduler as expected.
simTimes <- list(start = 0, end = 2) # need to figure out how to get it to be dynamic # have to add in clus object piece

## Setting up modules list 
moduleList <- list("FLEX") # Name of the modules to run

## Setting up parameters needed
## NOTE: If you provide an empty list of parameters, these are below are the 
## defaults
parameters <- list(
  FLEX = list(
    "simulations" = 5, # using 5 for ease of testing, change to 100 once running (number of simulations)
    "calculateInterval" = 1, # the simulation time at which adult female established territories are calculated
    "propFemales" = 0.3, 
    "maxAgeFemale" = 9,
    "D2_param" = c("Max","SD")
    )
)

## Setting up the outputs to be saved
outputs <- data.frame(
  objectName = "FLEX_output",
  saveTime = seq(simTimes[["start"]],
                 simTimes[["end"]], 
                 by = 1)
  )
  
mySim <- simInitAndSpades(times = simTimes,
                          modules = moduleList,
                          params = parameters,
                          outputs = outputs)

# Extract results from simulation

# Simulated start world
mySim$FLEX_setup$r_start
plot(mySim$FLEX_setup$r_start)

# Population and Habitat info at start
mySim$FLEX_setup$pop_info$suitable_habitat
mySim$FLEX_setup$pop_info$total_habitat
mySim$FLEX_setup$pop_info$perc_habitat
mySim$FLEX_setup$pop_info$numAF_start


# Full dataset at end of second iteration
mySim$FLEX_output

# Aggregated dataset
mySim$FLEX_agg_output
mySim$FLEX_multi_output

# Heatmap
mySim$FLEX_heatmap
raster::plot(mySim$FLEX_heatmap)

mySim$FLEX_multi_heatmap
raster::plot(mySim$FLEX_multi_heatmap)

# population start and predicted info
# need to remember what each value is really saying
# Mean number of fisher
mean(mySim$FLEX_heatmap@data@values)
# SE number of fisher
se <- function(x) sqrt(var(x)/length(x))
se(mySim$FLEX_heatmap@data@values)
# Predicted number of adult fishers with established territories at end of run
round(sum(mySim$FLEX_heatmap@data@values/5))
