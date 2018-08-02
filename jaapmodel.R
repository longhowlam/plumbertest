library(xgboost)
library(splines)
library(dplyr)
library(stringr)
library(analogsea)
library(plumber)


jaap = readRDS("Jaap_structured.RDs")
jaap = jaap %>% 
  filter(
    Oppervlakte < 1000, 
    Oppervlakte > 10, 
    kamers < 15,
    prijs > 75000, prijs < 1300000
  ) %>% 
  mutate(
    Type = str_trim(Type)
  )

huismodel1 = lm(prijs ~ Type +  Oppervlakte + kamers + PC, data = jaap)
huismodel2 = lm(prijs ~ Type +  ns(Oppervlakte,9) + kamers + PC, data = jaap)

summary(huismodel2)

saveRDS(huismodel2, "huismodel/huismodel2.RDs")

predict(
  huismodel2, 
  newdata = data.frame(
    Oppervlakte = 100,
    kamers = 3,
    PC = "16",
    Type = "Hoekwoning"
  )
)

######### deploy prediction model via plumber on DO ###################
d1 = droplets()


######## deploy plumber ##################
mydrop = d1$`house-model`

do_deploy_api(
  mydrop,
  "r_huisspline", "../plumbertest/huismodel/",
  8004, swagger = TRUE, forward = TRUE
)

http://188.166.112.55/r_huisspline/__swagger__/

curl -X POST "http://188.166.112.55/r_huisspline/rhuisspline?type=Hoekwoning&PC2=10&nkamers=4&opp=100" -H  "accept: application/json"