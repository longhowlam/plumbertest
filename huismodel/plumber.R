library(plumber)
library(splines)
library(xgboost)
library(Matrix)

### model objecten die we eerder gemaakt hebben
huismodel2 = readRDS("/var/plumber/r_huisspline/huismodel2.RDs")
xgb_model = readRDS("/var/plumber/r_huisspline/xgb_model.RDs")

### de verschillende levels die er zijn in Type en PC
Typelvl = readRDS("/var/plumber/r_huisspline/Typelvl.RDs")
PClvl = readRDS("/var/plumber/r_huisspline/PClvl.RDs")

#* @apiTitle Plumber huisprijs voorspeller linear model met spline.....


#* predict the value of a house with spline
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
  PC = factor(PC2, levels = PClvl)
  Type = factor(type,levels = Typelvl)

  pd = data.frame(PC, Type, Oppervlakte = as.numeric(opp), kamers = as.numeric(nkamers))
  tmp = sparse.model.matrix(  ~ PC + Oppervlakte + kamers + Type, data = pd)
  predict(xgb_model, newdata = tmp)
}