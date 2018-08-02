library(plumber)
library(splines)


huismodel2 = readRDS("/var/plumber/r_huisspline/huismodel2.RDs")

#* @apiTitle Plumber huisprijs voorspeller linear model met spline


#* predict the value of a house
#* @param opp Oppervlakte van huis in vierkante meters
#* @param nkamers aantal kamers huis
#* @param PC2 eerste twee cijfers van postcode waar huis staat
#* @param type type huis
#* @post /rhuisspline
function(opp, nkamers, PC2, type){
  browser()
  predict(
    huismodel2, 
    newdata = data.frame(
      Oppervlakte = as.numeric(opp),
      kamers = as.numeric(nkamers),
      PC = PC2,
      Type = type
    )
  )
}

#* Return the sum of two numbers
#* @param a The first number to add
#* @param b The second number to add
#* @post /sum
function(a, b){
  as.numeric(a) + 3*as.numeric(b)
}

