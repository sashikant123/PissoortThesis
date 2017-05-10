library(evd)
library(ggplot2)
library(PissoortThesis)


## Create data frames for ggplot
'GEVdfFun' <-
  function (x = seq(-10, 10, length = 10^3), mu = 0, sig = 1, ksi = 0) {
    if (ksi ==0) { dens <-  exp(-x) * exp(-exp(-x)) }
    else
      s <- (1 + ksi * (x - mu)/sig)^(-(ksi)^-1 - 1)
    t <- (1 + ksi * (x - mu)/sig)^(-(ksi)^-1)
    if (ksi < 0) {dens <-  s * exp(-t) * ( (x - mu)/sig  < -1/ksi ) }
    if (ksi > 0) {dens <- sig^{-1} * s * exp(-t) * ( (x - mu)/sig  > -1/ksi ) }

    df <- data.frame(x = x, density = dens, xi = as.factor(ksi),
                     mu = as.factor(mu), scale = as.factor(sig))
    return(df)
 }





shinyServer(function(input, output) {

  output$plot1 <- renderPlot({



    GEVdf <- rbind(GEVdfFun(mu = input$mu, sig=input$sig, ksi = input$ksi1),
                   GEVdfFun(mu = input$mu, sig=input$sig, ksi = 0),
                   GEVdfFun(mu = input$mu, sig=input$sig, ksi = input$ksi3))

    # Dealing with endpoints
    endpoint_w <- input$mu - (input$sig / input$ksi1)
    endpoint_f <- input$mu - (input$sig / input$ksi3)

    dens_f <- ifelse(GEVdf[GEVdf$xi == 0.5,]$density < endpoint_f, NA,
                     GEVdf[GEVdf$xi == 0.5,]$density )
    GEVdf[GEVdf$xi == 0.5,]$density <- dens_f


    # plot the normal distribution as reference

    GEVdf <- cbind(GEVdf, norm = dnorm(GEVdf$x, mean = input$mu, sd = input$sig))


    #GEVdf[GEVdf$density < 10^{-312}, ]$density <- NA

    pres <- labs(title = expression(paste(underline(bold('Generalized Extreme Value density')))),
                 colour = expression(paste(xi,"=")),linetype = expression(paste(xi,"=")))


    ggplot(GEVdf, aes(x = x, y = density, colour = xi )) +
      geom_line() + pres +
      geom_line(aes(x = x, y = norm, col = "normal"), col = "black", linetype = 3)+
      theme_piss(20, 15, theme_classic() ) +
      theme(legend.title = element_text(colour="#33666C",
                                        size=18, face="bold")) +
      theme(legend.key = element_rect(colour = "black")) +
      guides(colour = guide_legend(override.aes = list(size = 2))) +
      geom_point(aes(x = endpoint_f, y = 0),size = 3.5) +
      geom_point(aes(x = endpoint_w, y = 0), col="red",size = 3.5)

  })

})