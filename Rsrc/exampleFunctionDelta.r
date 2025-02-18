library(Rprebasso)

load("data/inputDataDeltaexample.rda")

### future weather - load the data for selected model and scenario
climateModel <- "CanESM2"       # "CanESM2" or "CNRM"
rcp <- "rcp45"                  # "rcp45" or "rcp85"

if(climateModel == "CanESM2") load(paste0("data/tranCanESM2.",rcp,".rda"))

if(climateModel == "CNRM")load(paste0("data/tranCNRM.",rcp,".rda"))

#load functions
devtools::source_url("https://raw.githubusercontent.com/ForModLabUHel/forClimate/main/Rsrc/dGrowthPrebas.r")
 
###multiite example
nYears=20
dGrowthExample <- dGrowthPrebas(nYears,siteInfo,initVar,
             currPAR=PARtran,newPAR=PARx,
             currTAir=TAirtran,newTAir=TAirx,
             currPrecip=Preciptran,newPrecip=Precipx,
             currVPD=VPDtran,newVPD=VPDx,
             currCO2=CO2tran,newCO2=CO2x)


#plot results for GrossGrowth
  dim(dGrowthExample$dV)
  plot(dGrowthExample$dV[1,,1])
  points(dGrowthExample$dV[1,,2],col=2)
  points(dGrowthExample$dV[1,,3],col=3)
hist(dGrowthExample$dV)
dVstand <- apply(dGrowthExample$dV,1:2,sum)
hist(dVstand)


#plot results for dH
dim(dGrowthExample$dH)
plot(dGrowthExample$dH[1,,1])
points(dGrowthExample$dH[1,,2],col=2)
points(dGrowthExample$dH[1,,3],col=3)
hist(dGrowthExample$dH)
dHStand <- apply(dGrowthExample$dH,1:2,sum)
hist(dHStand)


#plot results for dD
dim(dGrowthExample$dD)
plot(dGrowthExample$dD[1,,1])
points(dGrowthExample$dD[1,,2],col=2)
points(dGrowthExample$dD[1,,3],col=3)
hist(dGrowthExample$dD)
dDStand <- apply(dGrowthExample$dD,1:2,sum)
hist(dDStand)

###single Site example
nYears=20
siteX = 3 #select a site (from 1 to 7 from the previous dataset)
climID = 2 #select a climate (from 1 to 7 from the previous dataset)

siteInfo_siteX <- siteInfo[siteX,]
initVar_siteX <- initVar[siteX,,]

PAR_siteX <- PARtran[climID,]
newPAR_siteX <- PARx[climID,]
Precip_siteX <- Preciptran[climID,]
newPrecip_siteX <- Precipx[climID,]
TAir_siteX <- TAirtran[climID,]
newTAir_siteX <- TAirx[climID,]
VPD_siteX <- VPDtran[climID,]
newVPD_siteX <- VPDx[climID,]
CO2_siteX <- CO2tran[climID,]
newCO2_siteX <- CO2x[climID,]

dGrowthExample_siteX <- dGrowthPrebas(nYears,siteInfo_siteX,initVar_siteX,
                                currPAR=PAR_siteX,newPAR=newPAR_siteX,
                                currTAir=TAir_siteX,newTAir=newTAir_siteX,
                                currPrecip=Precip_siteX,newPrecip=newPrecip_siteX,
                                currVPD=VPD_siteX,newVPD=newVPD_siteX,
                                currCO2=CO2_siteX,newCO2=newCO2_siteX)


#plot results for GrossGrowth
dim(dGrowthExample_siteX$dV)
plot(dGrowthExample_siteX$dV[,1])
points(dGrowthExample_siteX$dV[,2],col=2)
points(dGrowthExample_siteX$dV[,3],col=3)
hist(dGrowthExample_siteX$dV)
dVstand <- apply(dGrowthExample_siteX$dV,1,sum)
hist(dVstand)

#plot results for dH
dim(dGrowthExample_siteX$dH)
plot(dGrowthExample_siteX$dH[,1])
points(dGrowthExample_siteX$dH[,2],col=2)
points(dGrowthExample_siteX$dH[,3],col=3)
hist(dGrowthExample_siteX$dH)
dHStand <- apply(dGrowthExample_siteX$dH,1,sum)
hist(dHStand)


#plot results for dD
dim(dGrowthExample_siteX$dD)
plot(dGrowthExample_siteX$dD[,1])
points(dGrowthExample_siteX$dD[,2],col=2)
points(dGrowthExample_siteX$dD[,3],col=3)
hist(dGrowthExample_siteX$dD)
dDStand <- apply(dGrowthExample_siteX$dD,1,sum)
hist(dDStand)

