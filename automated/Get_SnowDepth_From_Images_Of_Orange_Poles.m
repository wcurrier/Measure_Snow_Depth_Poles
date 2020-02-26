% Written by William Ryan Currier
% currierw@uw.edu

% Purpose: Load in images of an ORANGE/RED snow depth pole and find the number
% of pixels between the top and bottom

clear all; close all; clc

fontSize=12;

% Load images

% file_path='/Users/williamcurrier/Desktop/Orange_Poles/Orange_Poles_Test/test';   % original test images

file_path='/Users/williamcurrier/Documents/NASA_Fellowship/Orange_Poles/Orange_Poles_Test/test'; % snowEx Images
addpath(file_path)
listing = dir([file_path,'/*.JPG']);

count=0;
for i=1:size(listing,1) % started when there was snow and no tree in canopy
    
    count=count+1;
	%%%%%%%%%%%%%%%%%%%% Read in image into an array. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [rgbImage] = imread(listing(i).name);
    imshow(rgbImage)
    if count==1
        [X,Y]         = ginput(4); % select where to crop for all future images
    end
    rgbImage = (rgbImage(min(Y):max(Y),min(X):max(X),:)); % Clip the Image based on `ginput.m`

    % Break RGB image into seperate RGB matrices
	redBand = rgbImage(:, :, 1); 
	greenBand = rgbImage(:, :, 2); 
	blueBand = rgbImage(:, :, 3); 
  
    %%%%%%%%%%%%%%%%% Compute and Plot Histograms for Band in the Image %%%%%%%%%%%%%
    
    % NOTE: that this whole section can be commented out if you don't want to see the
    % histograms to build a better threshold
    
    % Compute and plot the red histogram. 
    figure
    set(gcf,'Position',[23         531        1658         302])
  	hR = subplot(1, 4, 2); 
	[countsR, grayLevelsR] = imhist(redBand); 
	maxGLValueR = find(countsR > 0, 1, 'last'); 
	maxCountR = max(countsR); 
	bar(countsR, 'r'); 
	grid on; 
	xlabel('Gray Levels'); 
	ylabel('Pixel Count'); 
	title('Histogram of Red Band', 'FontSize', fontSize);

	% Compute and plot the green histogram. 
	hG = subplot(1, 4, 3); 
	[countsG, grayLevelsG] = imhist(greenBand); 
	maxGLValueG = find(countsG > 0, 1, 'last'); 
	maxCountG = max(countsG); 
	bar(countsG, 'g', 'BarWidth', 0.95); 
	grid on; 
	xlabel('Gray Levels'); 
	ylabel('Pixel Count'); 
	title('Histogram of Green Band', 'FontSize', fontSize);

	% Compute and plot the blue histogram. 
	hB = subplot(1, 4, 4); 
	[countsB, grayLevelsB] = imhist(blueBand); 
	maxGLValueB = find(countsB > 0, 1, 'last'); 
	maxCountB = max(countsB); 
	bar(countsB, 'b'); 
	grid on; 
	xlabel('Gray Levels'); 
	ylabel('Pixel Count'); 
	title('Histogram of Blue Band', 'FontSize', fontSize);
    
	% Set all axes to be the same width and height.
	% This makes it easier to compare them.
	maxGL = 255; 
	maxCount = max([maxCountR,  maxCountG, maxCountB]); 
	axis([hR hG hB], [0 maxGL 0 maxCount]); 

	% Plot all 3 histograms in one plot.
	subplot(1, 4, 1); 
	plot(grayLevelsR, countsR, 'r', 'LineWidth', 2); 
	grid on; 
	xlabel('Gray Levels'); 
	ylabel('Pixel Count'); 
	hold on; 
	plot(grayLevelsG, countsG, 'g', 'LineWidth', 2); 
	plot(grayLevelsB, countsB, 'b', 'LineWidth', 2); 
	title('Histogram of All Bands', 'FontSize', fontSize);     
	maxGrayLevel = max([maxGLValueR, maxGLValueG, maxGLValueB]); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%% Now select thresholds for the 3 color bands. %%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
            % Take a guess at the values that might work for detecting red regions
            % Could improve this section
            
            redThresholdLow = graythresh(redBand);
            redThresholdHigh = 255;
            greenThresholdLow = 0;
            greenThresholdHigh = graythresh(greenBand);
            blueThresholdLow = 0;
            blueThresholdHigh = graythresh(blueBand);
            
                redThresholdLow = uint8(redThresholdLow * 255);
                greenThresholdHigh = uint8(greenThresholdHigh * 255);
                blueThresholdHigh = uint8(blueThresholdHigh * 255);

    %%%%%%%%%%%%%%%%%%%% Create Masks Based on Thresholds Above  %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        redMask = (redBand >= redThresholdLow) & (redBand <= redThresholdHigh);
        greenMask = (greenBand >= greenThresholdLow) & (greenBand <= greenThresholdHigh);
        blueMask = (blueBand >= blueThresholdLow) & (blueBand <= blueThresholdHigh);

        redObjectsMask = uint8(redMask & greenMask & blueMask);
    
    %%%%%%%%%%%%%%%%%%%% Plot Binary Masks and Some Subsequent Cleaning %%%%%%%%%%%%%%%%%%%%
            figure
            subplot(1,4,1)
            imshow(redObjectsMask, []);
            caption = sprintf('Mask of Only\nThe Red Objects');
            title(caption, 'FontSize', fontSize);    

            % We're going to filter out small objects.
            smallestAcceptableArea = 100; % Keep areas only if they're bigger than this.    
            redObjectsMask = uint8(bwareaopen(redObjectsMask, smallestAcceptableArea));
            subplot(1,4,2)
            imshow(redObjectsMask, []);
            fontSize = 13;
            caption = sprintf('bwareaopen() removed objects\nsmaller than %d pixels', smallestAcceptableArea);
            title(caption, 'FontSize', fontSize);

            % Smooth the border using a morphological closing operation, imclose().
            structuringElement = strel('disk', 4);
            redObjectsMask = imclose(redObjectsMask, structuringElement);
            subplot(1,4,3)
            imshow(redObjectsMask, []);
            fontSize = 16;
            title('Border smoothed', 'FontSize', fontSize);


            % Fill in any holes in the regions, since they are most likely red also.
            redObjectsMask = uint8(imfill(redObjectsMask, 'holes'));
            subplot(1,4,4)
            imshow(redObjectsMask, []);
            title('Regions Filled', 'FontSize', fontSize);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%% Detect the Top and Bottom %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%% of the Pole if the Mask Was Creaed Nicely   %%%%%%%%%%%%%%%%%%%%%%%%%%%

                % Hough Lines Code is the Algorithm that Detects the Longest Line
                [H,T,R] = hough(redObjectsMask,'Theta',-20:0.5:20);                 % hough function is designed to detect lines
                P  = houghpeaks(H,5,'threshold',ceil(0.5*max(H(:))));               % the 5 leads to 5 different lines from the Hough Matrix 
                lines = houghlines(redObjectsMask,T,R,P,'FillGap',2,'MinLength',7); % Extract line segments based on Hough transform.
                
    %%%%%%%%%%%%%%%%%%%%%%%%%% Plot Lines From Hough Transform %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
                figure, 
                subplot(1,2,1)
                imshow(rgbImage), hold on
                title(sprintf('%s\n%s','All Lines','Detected From Hough Transform'))
                
                max_len = 0; % initialize
                % Visualize X number of lines from the houghline output
                for k = 1:length(lines)
                   xy = [lines(k).point1; lines(k).point2];
                   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% 
%                    % Plot beginnings and ends of lines
                   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
                   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
                   
                   % Determine the endpoints, and length in pixels of the longest line segment
                   len = norm(lines(k).point1 - lines(k).point2);
                   if ( len > max_len)
                      max_len = len; % length in pixels
                      xy_long = xy;  % coordinates 
                      % xy_long
                      %     Row 1: End Point Coordinate:       X Coordinate in Column 1, Y Coordinate in Column 2
                      %     Row 2: Other End Point Coordinate: X Coordinate in Column 1, Y Coordinate in Column 2

                   end
                end

                % Plot the longest line segment to see how well the algorithm worked for each image
                    subplot(1,2,2),imshow(rgbImage)
                    title(sprintf('%s\n%s','Longest Line','Detected From Hough Transform'))
                    hold on
                    plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','blue');
                    plot(xy_long(1,1),xy_long(1,2),'ro');
                    plot(xy_long(2,1),xy_long(2,2),'bo');

                    pause()
    
    close all; clc


end
