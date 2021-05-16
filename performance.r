# Setup
# install.packages("tolerance")    # includes: plottol, regtol.int
# install.packages("readxl")       # includes: read_excel
# install.packages("qualityTools") # includes: mvPlot, qqPlot, tolerance
# install.packages("reshape")      # includes: transpose
# install.packages("RollingWindow") # NOT AVAILABLE FOR R version 3.6.0
# install.packages("RcppRoll")

source("F:\\Documents\\01_Dave's Stuff\\Engineering\\GitHub_repos\\R-setup\\setup.r")
setwd("F:\\Documents\\01_Dave's Stuff\\Engineering\\GitHub_repos\\finance_performance_R")

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
map  <- readall("performance_data.xlsx", sheet = 'Map',    skip=2)
## account <- map[, c('Account_Number', 'Owner', 'Owner_Group', 'Account_Name')]
value <- readall("performance_data.xlsx", sheet = 'valueR', skip=5)
twr   <- readall("performance_data.xlsx", sheet = 'TWRR',   skip=5)

printdf(account, 99, c('Account_Name'))

## identify column in value or twr that corresponds to ith account
account_col <- function(df, accountnum, dfa=map) {
  column <- which( names(df) == dfa[[accountnum, 'Account_Number']])
  return(column)
}
## 2nd account is tercentenary and values are in 4th column of value df
## account_col(value, 2)   # appropriately returns 4


## define S4 class account
## note need to access S4 class variables with @ rather than $ like for S3 class
setClass('account_class',
         slots = list(index  = 'number',
                      number = 'character',   # this will generally be a number but may not be
                      owner  = 'character',
                      group  = 'character',
                      name   = 'character',
                      ## date   = as.Date(x = integer(0), origin = "1970-01-01"),
                      date   = 'character',
                      ## date   = 'number',
                      value  = 'number',
                      twr    = 'number',
                      twrcum = 'number',
                      sd     = 'number'
                      )
         )

## create account objects
account <- function(i, dfmap=map, dfvalue=value, dftwr=twr) {
    account <- new('account_class',
                   number = dfmap[[i, 'Account_Number']],
                   owner  = dfmap[[i, 'Owner']],
                   group  = dfmap[[i, 'Owner_Group']],
                   name   = dfmap[[i, 'Account_Name']],
                   ## date   = as.list( as.Date(dfvalue[, 1], origin = '1970-01-01') ),
                   ## date   = as.list( dfvalue[, 1] ),
                   value  = as.list( dfvalue[, account_col(dfvalue, i)] ) )
    return(account)
}
account(1)


## example to deal with date
oblig <- setClass(
  "oblig", 
  slots = c(name="character",issue_date="Date"),
  prototype = list(
    name = character(0), 
    issue_date = Sys.Date()))
##
partial_init <- new("oblig", name = "TestOblig")
partial_init
partial_init@issue_date       # note use of @ rather than $ for class S4





account <- new('account_class',
               map[, c(number ='Account_Number',
                       owner  = 'Owner',
                       group  = 'Owner_Group',
                       name   = 'Account_Name')])
account



plotval <- function(accountnum, df=value, dfa=account) {
  column <- account_col(df, accountnum)
  plot(df$Date, df[, column])
}



plot(value$Date, value$`53580010`)


##--- STOPPED HERE --------------------------------------------------


## # Before dropping rows with N/A, reduce dataframe to only columns I care about
## #df <- subset(avg, select=c(avg$'US Large Cap',avg$'US Large Cap Value'))
## avg$US_L  <- as.numeric(avg$'US Large Cap')
## avg$US_LV <- as.numeric(avg$'US Large Cap Value')
## avg$US_LG <- as.numeric(avg$'US Large Cap Growth')
## avg$US_M  <- as.numeric(avg$'US Mid Cap')
## avg$US_MV <- as.numeric(avg$'US Mid Cap Value')
## avg$US_MG <- as.numeric(avg$'US Mid Cap Growth')
## avg$US_S  <- as.numeric(avg$'US Small Cap')
## avg$US_SV <- as.numeric(avg$'US Small Cap Value')
## avg$US_SG <- as.numeric(avg$'US Small Cap Growth')
## avg$Int_Dev         <- as.numeric(avg$'Intl Developed ex-US Market')
## avg$Int_Emg         <- as.numeric(avg$'Emerging Markets')
## avg$Bond_short      <- as.numeric(avg$'Short-Term Investment Grade')
## avg$Bond_high_yield <- as.numeric(avg$'High Yield Corporate Bonds')
## avg$REIT            <- as.numeric(avg$REIT)
## avg$Cash            <- as.numeric(avg$Cash)
## 
## df <- subset(avg,select=c(Year
##                           ,US_L,US_LV,US_LG
##                           ,US_M,US_MV,US_MG
##                           ,US_S,US_SV,US_SG
##                           ,Int_Dev, Int_Emg
##                           ,Bond_short, Bond_high_yield
##                           ,REIT, Cash)
##             )
## 
## df <- subset(avg,select=c(Year
##                           ,US_L
##                           ,US_M
##                           ,US_S
##                           ,Int_Dev, Int_Emg
##                           ,Bond_short, Bond_high_yield
##                           ,REIT, Cash)
##             )
## 
## # Convert "N/A" with what R considers to be NA and then drop those rows
## df <- df
## df[df == "N/A"]  <- NA
## df <- na.omit(df)             # drops rows with any NA values
## 
## # Calculate combinations
## df$roll_schwab_70_30 = 0.40*df$US_L + 0.13*df$US_S + 0.17*df$Int_Dev + 0.25*df$Bond_short + 0.05*df$Cash
## 
## # Create 1+avg_return dataframe
## df_plus1 <- df
## df_plus1[,2:ncol(df)] <- 1 + df_plus1[,2:ncol(df)]
## 
## # Create function to calculate rolling average for all except 1st column
## rolling_return <- function(df,nyr) {
## # rolling$US_L <- roll_prod(df_plus1$US_L, n=nyr, align="right", fill=0)^(1/nyr) - 1
## rolling <- df
## i <- 1
## for (col in 2:ncol(df)) {
## i <- i+1
## rolling[[i]] <- roll_prod(df[[i]], n=nyr, align="right", fill=0)^(1/nyr)
## }
## rolling[rolling == 0]  <- NA
## rolling <- na.omit(rolling)    # strip away rows with NA in them (i.e., previously blank)
## rolling[,2:ncol(rolling)] <- rolling[,2:ncol(rolling)] - 1
## return(rolling)   # needed to return the entire rollign dataframe and not just the last line in function
## }
## 
## # Calculate rolling 1 year average annual return
## rolling_1 <- rolling_return(df_plus1,1)
## 
## # Calculate rolling 3 year average annual return
## rolling_3 <- rolling_return(df_plus1,3)
## 
## # Calculate rolling 5 year average annual return
## rolling_5 <- rolling_return(df_plus1,5)
## 
## # Calculate rolling 10 year average annual return
## rolling_10 <- rolling_return(df_plus1,10)
## 
## # Plot assets against eachother
## pairs(rolling_3)
## #pairs(rolling_3[,1:4])
## 
## pairs(rolling_5)
## 
## pairs(rolling_10)
## 
## 
## 
## 
## 
## # Plot
## dfplot <- rolling_1
## ylabel <- "Rolling 1year return"
## x <- cbind(dfplot$Year, dfplot$Year, dfplot$Year, dfplot$Year)
## y <- cbind(dfplot$roll_schwab_70_30,  dfplot$US_LV,  dfplot$US_SV,  dfplot$Int_Emg)
## plot  (x=NULL, y=NULL, xlim=c(min(x),max(x)), ylim=c(min(y),max(y)), xlab="Year", ylab=ylabel)
## points(x[,1],y[,1], pch=1, lty=1, type="b")
## points(x[,2],y[,2], pch=2, lty=2, type="b")
## points(x[,3],y[,3], pch=3, lty=3, type="b")
## points(x[,4],y[,4], pch=4, lty=4, type="b")
## legend("bottomright",legend=c("Schwab 70/30","US_LV","US_SV","Int_Emg"),pch=1:4, lty=1:4)
## abline(h=0)
## 
## # Plot
## dfplot <- rolling_5
## ylabel <- "Rolling 5 year return"
## x <- cbind(dfplot$Year, dfplot$Year, dfplot$Year, dfplot$Year)
## y <- cbind(dfplot$roll_schwab_70_30,  dfplot$US_LV,  dfplot$US_SV,  dfplot$Int_Emg)
## plot  (x=NULL, y=NULL, xlim=c(min(x),max(x)), ylim=c(min(y),max(y)), xlab="Year", ylab=ylabel)
## points(x[,1],y[,1], pch=1, lty=1, type="b")
## points(x[,2],y[,2], pch=2, lty=2, type="b")
## points(x[,3],y[,3], pch=3, lty=3, type="b")
## points(x[,4],y[,4], pch=4, lty=4, type="b")
## legend("bottomright",legend=c("Schwab 70/30","US_L","US_LV","Int_Emg"),pch=1:4, lty=1:4)
## abline(h=0)
## 
## 
## 
## 
## 
## 
## 
## 
## 
## 
## points(dfplot$Year,dfplot$US_LV, pch=2, lty=2, type="b")
## points(dfplot$Year,dfplot$US_SV, pch=3, lty=3, type="b")
## points(dfplot$Year,dfplot$US_LG, pch=4, lty=4, type="b")
## legend("bottomright",legend=c("Schwab 70/30","US_L","US_LV","US_LG"),pch=1:4, lty=1:4)
## abline(h=0)
## 
## 
## plot  (dfplot$Year,dfplot$roll_schwab_70_30, pch=1, lty=1, type="b", xlab="Year", ylab=ylabel)
## points(dfplot$Year,dfplot$US_LV, pch=2, lty=2, type="b")
## points(dfplot$Year,dfplot$US_SV, pch=3, lty=3, type="b")
## points(dfplot$Year,dfplot$US_LG, pch=4, lty=4, type="b")
## legend("bottomright",legend=c("Schwab 70/30","US_L","US_LV","US_LG"),pch=1:4, lty=1:4)
## abline(h=0)
## 
## # Plot
## dfplot <- rolling_5
## ylabel <- "Rolling 5 year return"
## plot  (dfplot$Year,dfplot$US_L , pch=1, lty=1, type="b", xlab="Year", ylab=ylabel)
## points(dfplot$Year,dfplot$US_LV, pch=2, lty=2, type="b")
## points(dfplot$Year,dfplot$US_LG, pch=3, lty=3, type="b")
## points(dfplot$Year,dfplot$roll_schwab_70_30, pch=4, lty=4, type="b")
## legend("bottomright",legend=c("US_L","US_LV","US_LG","Schwab 70/30"), pch=1:4, lty=1:4)
## abline(h=0)
