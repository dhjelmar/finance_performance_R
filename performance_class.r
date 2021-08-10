# Setup
# install.packages("tolerance")    # includes: plottol, regtol.int
# install.packages("readxl")       # includes: read_excel
# install.packages("qualityTools") # includes: mvPlot, qqPlot, tolerance
# install.packages("reshape")      # includes: transpose
# install.packages("RollingWindow") # NOT AVAILABLE FOR R version 3.6.0
# install.packages("RcppRoll")

## set working folder
setwd("F:\\Documents\\01_Dave's Stuff\\Engineering\\GitHub_repos\\finance_performance_R")

## load generic modules
source("F:\\Documents\\01_Dave's Stuff\\Programs\\GitHub_home\\R-setup\\setup.r")
## load performance project modules
modpath <- c("f:/Documents/01_Dave's Stuff/Programs/GitHub_home/finance_performance_R/modules")
r_files <- list.files(modpath, pattern="*.[rR]$", full.names=TRUE)
for (f in r_files) {
  ## cat("f =",f,"\n")
  source(f)
}

## default origin for Excel since that is the source of date numbers
## excel <- '1900-01-01'       # this is what I thought it should be but does not work out right
excel <- '1899-12-30'
## as.numeric(as.Date(excel))  # returns -25569
## date_strings <- as.Date(as.numeric(date), origin=excel)

## library(tolerance)
## library(readxl)
## library(qualityTools)
## library(reshape)
## library(RollingWindow) # try RollingCompound function <-- failed
## library(RcppRoll)      # try roll_prod                <-- failed

##-----------------------------------------------------------------------------
## READ DATA
filename <- 'performance_data_example.xlsx'
map  <- readall(filename, sheet = 'Map',    header.row=3)
## account <- map[, c('Account_Number', 'Owner', 'Owner_Group', 'Account_Name')]
valuesheet <- readall(filename, sheet = 'value', header.row=6, rename=FALSE)
twrsheet   <- readall(filename, sheet = 'TWR',   header.row=6, rename=FALSE)

# ----------------------------------------------------
# CREATE ACCOUNT CLASS
setClass("account_class", 
         slots=list(key       = 'character', # also vector, matrix, array, data.frame
                    num       = 'numeric', 
                    owner     = 'character', 
                    group     = 'character', 
                    brokerage = 'character', 
                    name      = 'character',
                    date      = 'vector',
                    value     = 'vector',
                    twr       = 'vector')
        )

## CREATE ACCOUNT OBJECTS FROM THE MAP DATAFRAME

## ## following works but incorrectly made one, complicated object
## account <- new('account_class', 
##            key       = map$Account_Number,
##            num       = map$num,
##            owner     = map$Owner,
##            group     = map$Owner_Group,
##            brokerage = map$Brokerage,
##            name      = map$ACCOUNT_DESCRIPTION)

## following does not work either
## instead, try making one for each row in map
account <- 0     # initialize account
for (i in 1:nrow(map)) {
    account[i] <- new('account_class', 
                      key       = map$Account_Number,
                      num       = map$num,
                      owner     = map$Owner,
                      group     = map$Owner_Group,
                      brokerage = map$Brokerage,
                      name      = map$ACCOUNT_DESCRIPTION
                     )
}



## ADD DATE, VALUE, and TWR TO ACCOUNT
date  <- 0
value <- 0
twr   <- 0
for (i in 1:nrow(map)) {

  ## assign date field
  account@date[i]  <- list( valuesheet[[1]] )
  
  ## assign value field
  valuecol         <- which( names(valuesheet) == map[[i, 'Account_Number']])
  account@value[i] <- list( valuesheet[[valuecol]] )
  
  ## assign twr field
  twrcol           <- which( names(twrsheet)   == map[[i, 'Account_Number']])
  account@twr[i]   <- list( twrsheet[[twrcol]] )

}

account@key[1]
account[1]


##----------------------------------------------------
## CREATE  


## CREATE METHOD TO EXTRACT DATE RANGE AND PERFORM CALCULATIONS
## https://visualstudiomagazine.com/articles/2017/04/01/r-s4-demo.aspx
## Requires: setGeneric to tell R there is a function named, e.g., plot
##           setMethod to associate "plot" function with "account_class" class
setGeneric('daterange', def=function(obj) {standardGeneric('daterange')})
setMethod('daterange', 
          signature  = 'account_class',       # signature assigns applicable classes
          definition = function(obj) {
              ## date <- as.POSIXlt(obj@date)   # convert string to date
              twrp1 <- obj@twr + 1
              return(twrp1)
          }
          )

