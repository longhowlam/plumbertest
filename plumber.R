#
# This is a Plumber API. In RStudio 1.2 or newer you can run the API by
# clicking the 'Run API' button above.
#
# In RStudio 1.1 or older, see the Plumber documentation for details
# on running the API.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

huismodel2 = readRDS("huismodel/huismodel2.RDs")
library(plumber)

#* @apiTitle Plumber Example API

#* Echo back the input
#* @param msg The message to echo
#* @get /echo
function(msg=""){
  list(msg = paste0("The message is: '", msg, "'"))
}

#* Plot a histogram
#* @png
#* @get /plot
function(){
  rand <- rnorm(100)
  hist(rand)
}

#* Return the sum of two numbers
#* @param a The first number to add
#* @param b The second number to add
#* @post /sum
function(a, b){
  as.numeric(a) + 3*as.numeric(b)
}


#* predict the value of a house
#* @param opp Oppervlakte van huis in vierkante meters
#* @param nkamers aantal kamers huis
#* @param PC2 eerste twee cijfers van postcode waar huis staat
#* @param type type huis
#* @post /rhuisspline
function(opp, nkamers, PC2, type){
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



#* predict the value of a house with xgboost
#* @param opp Oppervlakte van huis in vierkante meters
#* @param nkamers aantal kamers huis
#* @param PC2 eerste twee cijfers van postcode waar huis staat
#* @param type type huis
#* @post /rhuisxgboost
function(opp, nkamers, PC2, type){
  PC = as.factor(PC2)
  levels(PC) = PClvl
  Type = as.factor(type)
  levels(Type) = Typelvl
  
  pd = data.frame(PC, Type, Oppervlakte = as.numeric(opp), kamers = as.numeric(nkamers))
  tmp = sparse.model.matrix(  ~ PC + Oppervlakte + kamers + Type, data = pd)
  predict(xgb_model, newdata = tmp)
}
