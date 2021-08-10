plotmake <- function(..., df=account, ylab='Value', main=NULL,
                     bg='grey90', legloc="bottomright",
                     output='screen', filename='performance') {
    accounts <- unlist( list(...) )
    nplots <- length(accounts)

    ## create dataframe of data to plot
    df <- plotdata(accounts)

    ## extract date for x-axis and requested parameter for y-axis
    date  <- df$date
    if (ylab == 'Value') {
        yplot <- df$value
    } else if (ylab == 'TWR') {
        yplot <- df$twr
    }
    
    ## set colors for plot lines
    pal <- rainbow(ncol(yplot))
    pal <- c('black', 'red', 'blue', '')
    pal <- c('red', 'darkorange2', 'goldenrod4', 'darkgreen', 
             'darkblue', 'darkorchid3', 'darkviolet', 
             'black', 'cyan3', 'tomato2', 'steelblue3')
    ## library(scales) # needed for show_col
    ## show_col(pal)

    ## initialize info for plot output if not to screen
    if (output == 'png' ) {
        png(filename=paste(filename, ".png", sep=""),
            type="cairo",
            units="in", 
            width=5, 
            height=4, 
            pointsize=12, 
            res=96)
    } else if (output == 'svg') {
        svg(filename=paste(filename, ".svg", sep=""),
            width=5, 
            height=4, 
            pointsize=12)
    }
    
    ## create plotspace
    par(bg=bg)  # changes background of plot to specified color
    plot(x=date, y=yplot[[1]], ylim=range(yplot), type='n',
         xlab='Date', ylab=ylab, main=main)
    ## add lines
    for (i in 1:nplots) {
        lines(x=date, y=yplot[[i]], lty=i, col=pal[i])
    }
    legend(legloc, col=pal, lty=1:nplots, legend=names(yplot))

    if (output != 'screen' ) dev.off()

    return(df)
    
}
# out <- plots(3,1,2, ylab='value', legloc='topleft')
# out <- plots(3,1,2, ylab='TWR', legloc='bottomleft')
