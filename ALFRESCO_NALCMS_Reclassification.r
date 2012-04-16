# this is a testing branch to come up with some new ways of classifying the NALCMS data
# lets bring in the library used to perform this task
require(raster)

# set the working dir
setwd("/workspace/UA/malindgren/projects/NALCMS_Veg_reClass/working_folder/")

# set an output directory
output.dir <- "/workspace/UA/malindgren/projects/NALCMS_Veg_reClass/outputs/run_6/"


# the input NALCMS 2005 Land cover raster
lc05 <- raster("/workspace/UA/malindgren/projects/NALCMS_Veg_reClass/NALCMS_VegReClass_Inputs/na_landcover_2005_1km_MASTER.tif")
north_south <- raster("/workspace/UA/malindgren/projects/NALCMS_Veg_reClass/NALCMS_VegReClass_Inputs/AKCanada_1km_NorthSouth_FlatWater_999_MASTER.tif")
mask <- raster("/workspace/UA/malindgren/projects/NALCMS_Veg_reClass/NALCMS_VegReClass_Inputs/AKCanada_PRISM_Mask_1km_gs_temp_version.tif")
gs_temp <- raster("/workspace/UA/malindgren/projects/NALCMS_Veg_reClass/NALCMS_VegReClass_Inputs/AKCanada_gs_temp_mean_MJJAS_1961_1990_climatology_1km_bilinear_MASTER.tif")
coast_spruce_bog <- raster("/workspace/UA/malindgren/projects/NALCMS_Veg_reClass/NALCMS_VegReClass_Inputs/Coastal_vs_Woody_wetlands_MASTER.tif")

#this next line just duplicates the input lc map and we will change the values in this map and write it to a TIFF
lc05.mod <- lc05
# remove the MASTER LC map
rm(lc05)
# create a vector of values from the NALCMS 2005 Landcover Map
v.lc05.mod <- getValues(lc05.mod)

# And the resulting 16 AK NALCMS classes are:
# 0 =  
# 1 = Temperate or sub-polar needleleaf forest
# 2 = Sub-polar taiga needleleaf forest
# 5 = Temperate or sub-polar broadleaf deciduous
# 6 = Mixed Forest
# 8 = Temperate or sub-polar shrubland
# 10 = Temperate or sub-polar grassland
# 11 = Sub-polar or polar shrubland-lichen-moss
# 12 = Sub-polar or polar grassland-lichen-moss 
# 13 = Sub-polar or polar barren-lichen-moss
# 14 = Wetland
# 15 = Cropland
# 16 = Barren Lands
# 17 = Urban and Built-up
# 18 = Water
# 19 = Snow and Ice

# COLLAPSES TO:
# 0 0 : 0
# 1 2 : 2
# 5 6 : 4
# 8 8 : 5
# 10 13 : 1
# 14 14 : 6 
# 15 19 : 0

# STEP 1



#reclassify the original NALCMS 2005 Landcover Map
# we do this via indexing the data we want using the builtin R {base} function which() and replace the values using the R {Raster}
# package function values() and assigning those values in the [index] the new value desired.

# begin by first collapsing down all classes from the original input that are not of interest to NOVEG
ind <- which(v.lc05.mod == 13 | v.lc05.mod == 15 | v.lc05.mod == 16 | v.lc05.mod == 17 | v.lc05.mod == 18 | v.lc05.mod == 19 | v.lc05.mod == 128); values(lc05.mod)[ind] <- 0 # rcl 13 & 15 thru 19 as 0

# Reclass the needleleaf classes to SPRUCE
ind <- which(v.lc05.mod == 1 | v.lc05.mod == 2); values(lc05.mod)[ind] <- 9 # SPRUCE PLACEHOLDER CLASS

# Reclass the deciduous and mixed as DECIDUOUS
ind <- which(v.lc05.mod == 5 | v.lc05.mod == 6); values(lc05.mod)[ind] <- 3 # Final Class

# Reclass the Temperate or sub-polar shrubland as SHRUB TUNDRA OR DECIDUOUS
#ind <- which(v.lc05.mod == 8); values(lc05.mod)[ind] <- 13 

# ind <- which(v.lc05.mod == 10); values(lc05.mod)[ind] <- 14 # Reclass Temperate or sub-polar grassland as GRAMMINOID TUNDRA and GRASSSLAND

# Reclass Sub-polar or polar shrubland-lichen-moss as SHRUB TUNDRA
ind <- which(v.lc05.mod == 11); values(lc05.mod)[ind] <- 4 

# Reclass Sub-polar or polar grassland-lichen-moss as GRAMMINOID TUNDRA
ind <- which(v.lc05.mod == 12); values(lc05.mod)[ind] <- 5


# ind <- which(v.lc05.mod == 14); values(lc05.mod)[ind] <- 15 #  ? Reclass Wetland to SPRUCE or WET TUNDRA (this is ultimately wet tundra and spruce bog differentiation)

#writeRaster(lc05.mod, filename=paste(output.dir,"NA_LandCover_2005_PRISM_extent_AKAlbers_1km_modal_simplifyClasses_step1.tif", sep=""), overwrite=TRUE)

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

# STEP 2

# here we are going to take the class SPRUCE or WET TUNDRA and break it down into classes of SPRUCE BOG or WETLAND TUNDRA or WETLAND
# get the values from the reclasification of Step 1
v.lc05.mod <- getValues(lc05.mod)

# get gs_temp layers values this is the one that will be used to determine the +/- growing season temperatures (6.0/6.5/7.0)
v.gs_temp <- getValues(gs_temp)

# lets get the values of the Coastal_vs_Spruce_bog layer that differentiates the different wetland classes
v.coast_spruce_bog <- getValues(coast_spruce_bog)

# now we index the values we want to use for this step of the reclass
# [version2] these values have been altered from the original version and will be reclassed now into wetland tundra and coastal spruce bog


# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# touch base with Amy about whether this is an ok differentiation to create.  Where only the Wetland Tundra occurs at the coast and not in the interior?

ind <- which(v.lc05.mod == 14 & v.coast_spruce_bog == 2); values(lc05.mod)[ind] <- 9 # reclassed into SPRUCE placeholder class

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


ind <- which(v.lc05.mod == 14 & v.coast_spruce_bog != 2); values(lc05.mod)[ind] <- 20 # reclassed to a PlaceHolder class of 20 (coastal wetland)


# rm(v.coast_spruce_bog)
# rm(coast_spruce_bog)

# write out and intermediate raster for review
# writeRaster(lc05.mod, filename=paste(output.dir, "NA_LandCover_2005_PRISM_extent_AKAlbers_1km_ALFRESCO_Step2.tif", sep=""), overwrite=TRUE)
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Step 3 here the coastal wetland class is going to be reclassified into WETLAND TUNDRA or NO VEG
v.lc05.mod <- getValues(lc05.mod)

# here we are taking the placeholder class of 20 and turning it into Wetland Tundra and NoVeg
ind <- which(v.lc05.mod == 20 & v.gs_temp < 6.5); values(lc05.mod)[ind] <- 6 # this is a FINAL CLASS WETLAND TUNDRA

# here we turn the remainder of the placeholder class into noVeg
ind <- which(v.lc05.mod == 20 & v.gs_temp >= 6.5); values(lc05.mod)[ind] <- 0 


# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
# STEP 4
# lets turn the placeholder class 13 (Temperate or sub-polar shrubland) into DECIDUOUS or SHRUB TUNDRA

v.lc05.mod <- getValues(lc05.mod)

# now lets find the values we need for this reclassification step
ind <- which(v.lc05.mod == 8 & v.gs_temp < 6.5); values(lc05.mod)[ind] <- 4 # this is the final class of SHRUB TUNDRA
ind <- which(v.lc05.mod == 8 & v.gs_temp > 6.5); values(lc05.mod)[ind] <- 3 # this is the final class of DECIDUOUS

# writeRaster(lc05.mod, filename=paste(output.dir, "NA_LandCover_2005_PRISM_extent_AKAlbers_1km_ALFRESCO_Step3.tif", sep=""), overwrite=TRUE)

# now I am going to complete the reclassification of the NALCMS class 10 Temperate or sub-polar grassland to GRAMMINOID TUNDRA and GRASSSLAND (NoVeg)
ind <- which(v.lc05.mod == 10 & v.gs_temp < 6.5); values(lc05.mod)[ind] <- 5 # GRAMMINOID TUNDRA
ind <- which(v.lc05.mod == 10 & v.gs_temp > 6.5); values(lc05.mod)[ind] <- 0 # GRASSLAND becomes NOVEG



# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

# STEP 5

v.lc05.mod <- getValues(lc05.mod)

#Now we bring the north_south map into the mix to differentiate between the white and black spruce from the SPRUCE class
v.north_south <- getValues(north_south)

# we need to examine the 2 placeholder classes for SPRUCE class and parse them out in to WHITE / BLACK.  
# if any pixels in the 2 spruce classes are north facing and have gs_temps > 6.5 then it is WHITE SPRUCE
ind <- which(v.lc05.mod == 9 & (v.gs_temp > 6.5 | v.north_south == 2)); values(lc05.mod)[ind] <- 2 # FINAL WHITE SPRUCE CLASS

# if any pixels in the 2 spruce classes are north facing and have gs_temps < 6.5 then it is BLACK SPRUCE
#  ** should there be a class where if it is southfacing and gs_temps < 6.5 then it is BLACK SPRUCE????
ind <- which(v.lc05.mod == 9 & v.north_south == 1); values(lc05.mod)[ind] <- 2 # FINAL BLACK SPRUCE CLASS

# get those values again
v.lc05.mod <- getValues(lc05.mod)

# # now we take the remainder of those 2 SPRUCE CLASSES and give them class BLACK if Noth facing and WHITE if South facing
ind <- which(v.lc05.mod == 9 & v.north_south == 2); values(lc05.mod)[ind] <- 1
ind <- which(v.lc05.mod == 9 & v.north_south != 2); values(lc05.mod)[ind] <- 2


#writeRaster(lc05.mod, filename=paste(output.dir, "NA_LandCover_2005_PRISM_extent_AKAlbers_1km_ALFRESCO_Step4.tif", sep=""), overwrite=TRUE)













# # -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

# # STEP 5

# v.lc05.mod <- getValues(lc05.mod)

# # Here we will reclass the spruce class to black or white spruce

# ind <- which(v.lc05.mod == 2 & (v.gs_temp < 6.5 | v.north_south == 1)); values(lc05.mod)[ind] <- 3

# writeRaster(lc05.mod, filename=paste(output.dir, "NA_LandCover_2005_PRISM_extent_AKAlbers_1km_ALFRESCO_Step5.tif", sep=""), overwrite=TRUE)

# -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

# STEP 6 -- FINAL

v.lc05.mod <- getValues(lc05.mod)

# this is the final reclass step to bring the NALCMS map back to the ALFRESCO classification

#ind <- which(v.lc05.mod == 5); values(lc05.mod)[ind] <- 2


# now I will write out the raster file

writeRaster(lc05.mod, filename=paste(output.dir, "NA_LandCover_2005_PRISM_extent_AKAlbers_1km_ALFRESCO_FINAL.tif", sep=""), overwrite=TRUE)


