# Measure_Snow_Depth_Poles

# Atuomated method:

Only works for orange poles.

You'll need to first provide the filepath to where all the images are by updating line 15.

An image will pop up, click 4 times in a ~rectangle around the pole - allow some buffer as the cameras likely moved, or the poles moved.

The code currently determines the number of pixels from the top of the pole to the bottom-most-visible part of the pole - this variable is called `max_len`.
From there, you should be able to derive snow depth if you know the number of pixels for the length of the pole when there's no snow. 
You'll have to write this part into the script and determine how you want to store it into a time-series. Using the `listing.date` variable might be useful. This part should be easy. 

# Non-automated method

The remaining scripts will allow for a semi-automated method where you click the top and bottom of the pole to get the measurements. This method, along with all uncertainties in determining snow depth from camera images and poles are described in Chapter II of Currier 2017: https://digital.lib.washington.edu/researchworks/handle/1773/38604
