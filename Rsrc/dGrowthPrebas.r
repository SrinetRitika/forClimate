###function for delta growth calculation
#' dGrowthPrebas
#'
#' @param nYears number of year for the simulations
#' @param siteInfo site information table. (rows=nSites x column=12 Matrix) Matrix of site info: SiteID, climID, siteType, SWinit (initial soil water), CWinit (initial crown water), SOGinit (initial snow on ground), Sinit (initial temperature acclimation state), nLayers, nSpecies, soildepth, effective field capacity, permanent wilthing point. Default = c(1,1,3, 160, 0, 0, 20, 413.,0.45, 0.118), i.e. siteType = 3. Give for homogeneous sites as siteInfo <- matrix(c(NA,NA,3,160,0,0,20,nLayers,3,413,0.45,0.118),nSites,12,byrow = T) # Set site index values to siteInfo columns 1-2 siteInfos[,2] <- siteInfos[,1] <- 1:nSites
#' @param initVar 	(nSite x 7 x nLayer array) Array with initial stand values for all the tree strata in each site. Third dimension corresponds to the layers in the stand. Initial information needed are: SpeciesID (a number corresponding to the species parameter values of pPRELES columns), Age (years), average height of the layer (H, m), average diameter at breast height of the layer (D, cm), basal area of the layer (BA, m2 ha-1), average height of the crown base of the layer (Hc, m). 8th column is updated automatically to Ac. If initVar is not provided the model is initialized from plantation using default planting parameters (see initClearcut) and assuming that Pine, Spruce and Birch are equally present at plantation.
#' @param currPar 	PAR for current weather (nSites x nYears*365 matrix) A numeric matrix of daily sums of photosynthetically active radiation, mmol/m2, for each site.
#' @param newPAR    PAR for new weather (nSites x nYears*365 matrix) A numeric matrix of daily sums of photosynthetically active radiation, mmol/m2, for each site.
#' @param currTAir air temperature for current weather (nSites x nYears*365 matrix) A numeric matrix of daily mean temperature, degrees C, for each site.
#' @param newTAir air temperature for new weather (nSites x nYears*365 matrix) A numeric matrix of daily mean temperature, degrees C, for each site.
#' @param currPrecip Precipitation for current weather (nSites x nYears*365 matrix) A numeric matrix of daily rainfall, mm, for each site.
#' @param newPrecip Precipitation for new weather (nSites x nYears*365 matrix) A numeric matrix of daily rainfall, mm, for each site.
#' @param currVPD VPD for current weather (nSites x nYears*365 matrix) A numeric matrix of daily mean vapour pressure deficits, kPa, for each site.
#' @param newVPD VPD for new weather (nSites x nYears*365 matrix) A numeric matrix of daily mean vapour pressure deficits, kPa, for each site.
#' @param currCO2 CO2 for current weather (nSites x nYears*365 matrix) A numeric matrix of air CO2, ppm, for each site.
#' @param newCO2 CO2for new weather (nSites x nYears*365 matrix) A numeric matrix of air CO2, ppm, for each site.
#'
#' @return a list of 3 3-dimensional array (nSites x nYears x nLayers) of deltas for gross growth (dGrowth), Height (dH) and dbh (dD)
#' 
#' @export
#'
#' @examples
#' # define the number of years for the simulation and run the function for 7 sites using the example weather data
#' nYears=20
#' dGrowthExample <- dGrowthPrebas(nYears,siteInfo,initVar,currPar=PARtran,newPAR=PARx,currTAir=TAirtran,newTAir=TAirx,currPrecip=Preciptran,newPrecip=Precipx,currVPD=VPDtran,newVPD=VPDx,currCO2=CO2tran,newCO2=CO2x)

dGrowthPrebas <- function(nYears,siteInfo,initVar,
                          currPAR,newPAR,
                          currTAir,newTAir,
                          currPrecip,newPrecip,
                          currVPD,newVPD,
                          currCO2,newCO2,
                          ClCut = 0,
                          defaultThin = 0
){
  if(is.null(nrow(siteInfo)) & length(siteInfo==12)){
    nSites <- 1
  }else{
    nSites <- nrow(siteInfo)  
  }
  
  if(nSites>1){
    initCurr <- InitMultiSite(nYearsMS = rep(nYears,nSites),
                              PAR = currPAR,
                              VPD = currVPD,
                              CO2 = currCO2,
                              TAir = currTAir,
                              Precip = currPrecip,
                              siteInfo = siteInfo,
                              multiInitVar = initVar,
                              ClCut = ClCut,
                              defaultThin = defaultThin)
    modOutCurr <- multiPrebas(initCurr)
    
    initNew <- InitMultiSite(nYearsMS = rep(nYears,nSites),
                             PAR = newPAR,
                             VPD = newVPD,
                             CO2 = newCO2,
                             TAir = newTAir,
                             Precip = newPrecip,
                             siteInfo = siteInfo,
                             multiInitVar = initVar,
                             ClCut = ClCut,
                             defaultThin = defaultThin)
    modOutNew <- multiPrebas(initNew)
    if(dim(modOutNew$multiInitVar)[3]>1){
      dimX <- dim(modOutNew$multiOut[,,11,,1]);dimX[2] <- nYears +1
      xx <- array(NA,dim = dimX)
      if (length(dimX)>2){
        xx[,2:(nYears+1),] <- modOutNew$multiOut[,,11,,1]
        xx[,1,] <- modOutNew$multiInitVar[,3,]
        dGrowthH <- xx[,2:(nYears+1),] - xx[,2:(nYears+1),]
        
      }
    }
    growthCurr <- dGrowthVars(modOutCurr)
    growthNew <- dGrowthVars(modOutNew)
    
    dH <-growthNew$dGrowthH/growthCurr$dGrowthH
    dD <-growthNew$dGrowthD/growthCurr$dGrowthD
    dN <-growthNew$dGrowthN/growthCurr$dGrowthN
    dB <-growthNew$dGrowthB/growthCurr$dGrowthB
    dV <-modOutNew$multiOut[,,43,,1]/modOutCurr$multiOut[,,43,,1]
  }else{
    modOutCurr <- prebas(nYears = nYears,
                         PAR = currPAR,
                         VPD = currVPD,
                         CO2 = currCO2,
                         TAir = currTAir,
                         Precip = currPrecip,
                         siteInfo = siteInfo,
                         initVar = initVar,
                         ClCut = ClCut,
                         defaultThin = defaultThin)
    
    modOutNew <- prebas(nYears = nYears,
                        PAR = newPAR,
                        VPD = newVPD,
                        CO2 = newCO2,
                        TAir = newTAir,
                        Precip = newPrecip,
                        siteInfo = siteInfo,
                        initVar = initVar,
                        ClCut = ClCut,
                        defaultThin = defaultThin)
    
    growthCurr <- dGrowthVars(modOutCurr)
    growthNew <- dGrowthVars(modOutNew)
    
    dH <-growthNew$dGrowthH/growthCurr$dGrowthH
    dD <-growthNew$dGrowthD/growthCurr$dGrowthD
    dN <-growthNew$dGrowthN/growthCurr$dGrowthN
    dB <-growthNew$dGrowthB/growthCurr$dGrowthB
    dV <-modOutNew$output[,43,,1]/modOutCurr$output[,43,,1]
  }
  
  return(list(dH=dH,dD=dD,dB=dB,dN=dN,dV=dV))
}


dGrowthVars <- function(modOut){
  if(class(modOut)=="multiPrebas"){
    nYears <- modOut$maxYears
    dimX <- dim(modOut$multiOut[,,11,,1]);dimX[2] <- nYears +1
    xx <- array(NA,dim = dimX)
    if(length(dimX)>2){
      # H
      xx[,2:(nYears+1),] <- modOut$multiOut[,,11,,1]
      xx[,1,] <- modOut$multiInitVar[,3,]
      dGrowthH <- xx[,2:(nYears+1),] - xx[,1:nYears,]
      # D      
      xx[,2:(nYears+1),] <- modOut$multiOut[,,12,,1]
      xx[,1,] <- modOut$multiInitVar[,4,]
      dGrowthD <- xx[,2:(nYears+1),] - xx[,1:nYears,]
      # B
      xx[,2:(nYears+1),] <- modOut$multiOut[,,13,,1]
      xx[,1,] <- modOut$multiInitVar[,5,]
      dGrowthB <- xx[,2:(nYears+1),] - xx[,1:nYears,]
      # N
      xx[,2:(nYears+1),] <- modOut$multiOut[,,17,,1]
      xx[,1,] <- modOut$multiInitVar[,5,]/(pi*(modOut$multiInitVar[,4,]/200)^2)
      dGrowthN <- xx[,2:(nYears+1),] - xx[,1:nYears,]
    }else{
      # H
      xx[,2:(nYears+1)] <- modOut$multiOut[,1:20,11,,1]
      xx[,1] <- modOut$multiInitVar[,3,]
      dGrowthH <- xx[,2:(nYears+1)] - xx[,1:nYears]
      # D      
      xx[,2:(nYears+1)] <- modOut$multiOut[,,12,,1]
      xx[,1] <- modOut$multiInitVar[,4,]
      dGrowthD <- xx[,2:(nYears+1)] - xx[,1:nYears]
      # B
      xx[,2:(nYears+1)] <- modOut$multiOut[,,13,,1]
      xx[,1] <- modOut$multiInitVar[,5,]
      dGrowthB <- xx[,2:(nYears+1)] - xx[,1:nYears]
      # N
      xx[,2:(nYears+1)] <- modOut$multiOut[,,17,,1]
      xx[,1] <- modOut$multiInitVar[,5,]/(pi*(modOut$multiInitVar[,4,]/200)^2)
      dGrowthN <- xx[,2:(nYears+1)] - xx[,1:nYears]
    }
  }else{####for single site runs
    nYears <- modOut$nYears
    if(modOut$nLayers>1){
      # H
      xx <- rbind(modOut$initVar[3,],modOut$output[,11,,1])
      dGrowthH <- xx[2:(nYears+1),] - xx[1:nYears,]
      # D      
      xx <- rbind(modOut$initVar[4,],modOut$output[,12,,1])
      dGrowthD <- xx[2:(nYears+1),] - xx[1:nYears,]
      # B
      xx <- rbind(modOut$initVar[5,],modOut$output[,13,,1])
      dGrowthB <- xx[2:(nYears+1),] - xx[1:nYears,]
      # N
      xx <- rbind(modOut$initVar[5,],modOut$output[,17,,1])
      xx[1,] <- modOut$initVar[5,]/(pi*(modOut$initVar[4,]/200)^2)
      dGrowthN <- xx[2:(nYears+1),] - xx[1:nYears,]
    }else{
      # H
      xx <- c(modOut$initVar[3],modOut$output[,11,1,1])
      dGrowthH <- xx[2:(nYears+1)] - xx[1:nYears]
      # D      
      xx <- c(modOut$initVar[4],modOut$output[,12,1,1])
      dGrowthD <- xx[2:(nYears+1)] - xx[1:nYears]
      # B
      xx <- c(modOut$initVar[5],modOut$output[,13,1,1])
      dGrowthB <- xx[2:(nYears+1)] - xx[1:nYears]
      # N
      xx <- c(modOut$initVar[5],modOut$output[,17,1,1])
      xx[1] <- modOut$initVar[5]/(pi*(modOut$initVar[4]/200)^2)
      dGrowthN <- xx[2:(nYears+1)] - xx[1:nYears]
    }
  }
  return(list(dGrowthH=dGrowthH,dGrowthD=dGrowthD,dGrowthB=dGrowthB,dGrowthN=dGrowthN))
}
