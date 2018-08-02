library(analogsea)
library(plumber)


#### provision a droplet with neccesary R and plumber software
d1 = droplets()
mydrop = plumber::do_provision(d1$`house-model`)


#### during provisioning UFW is installed, to allow traffic ports use

sudo ufw allow 12000
ufw status verbose

######## deploy plumber ##################

do_deploy_api(mydrop, "testlhl2", "../plumber_test/", 8003, swagger = TRUE, forward = TRUE)

########### plumber call ##################

curl -X POST "http://188.166.112.55/testlhl2/sum?b=1&a=2" -H  "accept: application/json"

http://188.166.112.55/testlhl2/__swagger__/

####################################################################
droplets()
droplets() %>% droplets_cost()
droplets()
analogsea::snapshots()
