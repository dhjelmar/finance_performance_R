plotdata <- function(..., df=account) {
    accounts <- unlist( list(...) )
    nplots <- length(accounts)

    date  <- df$date[[1]]

    ## initialize parameters
    name  <- NULL
    value <- data.frame(date)
    twr   <- data.frame(date)
    
    ## create dataframes of parameters to be plotted
    for (i in 1:nplots) {
        j <- as.numeric(accounts[i])
        name[i]  <- as.character( df$name[[j]]  )
                                        # value[i] <- list(as.numeric( df$value[[j]] ))
                                        # twr[i]   <- list(as.numeric( df$twr[[j]]   ))
        value <- cbind(value, as.numeric( df$value[[j]] ))
        twr   <- cbind(twr,   as.numeric( df$twr[[j]]   ))
    }
    names(value) <- c('Date', name)
    value <- as_tibble( as.data.frame(value) )
    names(twr)   <- c('Date', name)
    twr   <- as_tibble( as.data.frame(twr)   )

    return(list(value=value, twr=twr))
    
}
## df <- plotdata(3,2)
