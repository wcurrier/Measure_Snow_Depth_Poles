# Measure_Snow_Depth_Poles
Measure snow depth from camera images and poles automatically or semi-automatically.
# Atuomated method:

Only works for orange poles.

## Processing Notes:

You'll need to first provide the filepath to where all the images are by updating line 15.

An image will pop up, click 4 times in a ~rectangle around the pole - allow some buffer as the cameras likely moved, or the poles moved.

## Methods:

Right now, the code reads in an image and searches for areas that are red/orange to create a binary image (1 = orange/red, 0 = other colors). From that binary image, a hough transform is applied, which searches for various lines in the binary image. The lines hopefully correspond to the pole. We take the longest line that was detected. Along with the line, the distance in pixels between the top and bottom of the pole is found. From there, along with the height of the pole, the snow depth can be determined.

There could also be some easy quality control thrown in here. Sometimes it doesn't create a good enough binary image and therefore the line detected is too high/too low or way too small. We could just thrown these points out and interpolate between them?

The code currently determines the number of pixels from the top of the pole to the bottom-most-visible part of the pole - this variable is called `max_len`.

From there, you should be able to derive snow depth if you know the number of pixels for the length of the pole when there's no snow. 

You'll have to write this part into the script and determine how you want to store it into a time-series. Using the `listing.date` variable might be useful. This part should be easy. 

# Non-automated method

The remaining scripts will allow for a semi-automated method where you click the top and bottom of the pole to get the measurements. This method, along with all uncertainties in determining snow depth from camera images and poles are described in Chapter II of Currier 2017: https://digital.lib.washington.edu/researchworks/handle/1773/38604
