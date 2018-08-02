library(xgboost)
library(splines)
library(dplyr)
library(stringr)
library(analogsea)
library(plumber)
library(Matrix)

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

########## xgboost model #######################################################

#### haal missings weg
jaap = jaap %>% filter(
  !is.na(prijs),
  !is.na(PC),
  !is.na(Oppervlakte)
)

#### xgboost needs model matrix
xgb_model = sparse.model.matrix(
  prijs ~ PC + Oppervlakte + kamers + Type,
  data = jaap
) %>% 
xgboost(
  label = jaap$prijs,
  nrounds = 500, verbose = 1, print_every_n = 10L
)

#### model output and diagnostics        
xgb_model
xgb.importance( colnames(trainm), model =xgb_model)

xgb.plot.tree(colnames(trainm), model = xgb_model, n_first_tree = 3)

p = xgb.plot.multi.trees(
  model = xgb_model,
  feature_names = colnames(trainm),
  features_keep = 30
)
print(p)

######### xgboost predicties ##########################
#levels nodig van factor variabelen
PClvl = levels(as.factor(jaap$PC))
Typelvl = levels(as.factor(jaap$Type))

PC = as.factor("10")
levels(PC) = PClvl
Type = as.factor("Hoekwoning")
levels(Type) = Typelvl

pd = data.frame(PC, Type, Oppervlakte = 50, kamers = 4)
tmp = sparse.model.matrix(  ~ PC + Oppervlakte + kamers + Type, data = pd)
predict(xgb_model, newdata = tmp)

saveRDS(Typelvl, "huismodel/Typelvl.RDs")
saveRDS(PClvl, "huismodel/PClvl.RDs")
saveRDS(xgb_model, "huismodel/xgb_model.RDs")

######### deploy prediction model via plumber on DO ###################
d1 = droplets()


######## deploy plumber ##################
mydrop = d1$`house-model`

do_deploy_api(
  mydrop,
  "r_huisspline", "../plumbertest/huismodel/",
  8004, swagger = TRUE, forward = TRUE
)

######### voorbeeld aanroepen ######################
http://188.166.112.55/r_huisspline/__swagger__/

curl -X POST "http://188.166.112.55/r_huisspline/rhuisspline?type=Hoekwoning&PC2=10&nkamers=4&opp=100" -H  "accept: application/json"

