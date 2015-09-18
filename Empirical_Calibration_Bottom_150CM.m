%% Find Files & Put in Metadata

% This code allows you to calibrate a Snow Depth pole. It assumes you're
% working with a snow depth pole that has tick marks every 5 centimeters
% This code in particular only focuses on the bottom 150 cm, which allows
% you to build a bounding box around this area and zoom in to get a more
% accurate measurement. It also makes the calibration process quicker and
% the other tick marks are not needed if theres no snow there.

clear all; close all; clc % fresh start
set(0,'DefaultFigurePosition',[0          41*40        658       658]); % changes the size of the window

% You'll need to update these paths based on where you've stored your images the first addpath should simply just add the directory, while the second should include the wildcard *.JPG at the end.
addpath('/Users/wcurrier/Desktop/Matlab_Functions') % you may need some functions but I don't think so
addpath('/Volumes/Seagate_Backup_Plus_Drive/OLYMPEX_Photos/Mount_Seattle_West_Images/Camera_1/'); % path to where all your photos are
listing = dir('/Volumes/Seagate_Backup_Plus_Drive/OLYMPEX_Photos/Mount_Seattle_West_Images/Camera_1/*.JPG'); % path to where

numImgs = size(listing,1); % determines the number of images in the directory you pointed to


site_name='Mount_Seattle_West';
Declination_Angle='31 degrees';
color='Black_and_White';
Height_of_Camera=6.19; % meters
Distance_to_Pole=8.8; % cm
Elevation=4496; %feet
Lat=47.715133333333334; % decimal degrees N
Long=-123.58985; % decimal degrees W
camera_number=1;
pole_number=2;
pole_length=400; % centimeters
NumberOfTicks=31; % Number of ticks - bottom 150 centimeters should have 31 tick marks (including the 150 mark and the bottom of the pole
measure_bottom=150; % The number of centimeters you're calibrating to.
Image_Number=[66 150 860 870]; % Based on the listing what is the image number that you want to calibrate to
Image_name=listing(Image_Number).name;

%% Code Starts Here
for ii=1:length(Image_Number)
    close all
    
 % Store the name of the image you used to calibrate

    Image_name=listing(Image_Number).name; % Store the name of the image you used to calibrate
                originalImage = imread(listing(Image_Number(ii)).name); % read in Calibration Image
                RotatedImage = imrotate(originalImage,90); % Rotate Image so that you can make it larger on your screen
                imshow(RotatedImage); % show image
                
                [X,Y]         = ginput(4); % crop the image by clicking around the top of the pole
                cropped_RotatedImage=RotatedImage(min(Y):max(Y),min(X):max(X),:);
                    
                    imshow(cropped_RotatedImage,'InitialMagnification', 400) % show cropped image
                    [ClickCoordinates]         = ginput(1); % click the top of the pole
                    
                    % Store the Coordinates corrected for the non-cropped image
                    ClickCoordinates2(1,1 )=min(X)+ClickCoordinates(1,1); % get the coordinates so they make sense based on the original image
                    ClickCoordinates2(1,2)=min(Y)+ClickCoordinates(1,2); % get the coordinates so they make sense based on the original image
                    
                    close all
                    
                originalImage = imread(listing(Image_Number(ii)).name); % read in Calibration Image
                RotatedImage = imrotate(originalImage,90); % Rotate Image so that you can make it larger on your screen
                imshow(RotatedImage); % show image
                
                [X,Y]         = ginput(4); % crop the image by clicking around the bottom 150 cm
                cropped_RotatedImage=RotatedImage(min(Y):max(Y),min(X):max(X),:);
                    
                    imshow(cropped_RotatedImage,'InitialMagnification', 400) % show cropped image
                    [ClickCoordinates]         = ginput(NumberOfTicks); % click the bottom 150 cm
                    
                    % Store the Coordinates corrected for the non-cropped image
                    ClickCoordinates2(2:NumberOfTicks+1,1)=min(X)+ClickCoordinates(1:NumberOfTicks,1); % get the coordinates so they make sense based on the original image
                    ClickCoordinates2(2:NumberOfTicks+1,2)=min(Y)+ClickCoordinates(1:NumberOfTicks,2); % get the coordinates so they make sense based on the original image

                    

                    %View Calibration
                    imshow(RotatedImage),hold on
                    plot(ClickCoordinates2(:,1),ClickCoordinates2(:,2),'o')
                    pause()
                    hold off              
%% Calculate Distances and Creat Look Up Table
Distances=nan(length(ClickCoordinates2),1);
for kk=1:length(ClickCoordinates2) % Use the Distance Formula To Calculate Distances
    Distances(kk,1)=sqrt((ClickCoordinates2(1,1)-ClickCoordinates2(kk,1))^2+(ClickCoordinates2(1,2)-ClickCoordinates2(kk,2))^2);
end

% Create Look Up Table

% Original Lookup Table Based on Clicks - this includes the coordinates of
% where you click
    originaltable=[0,ClickCoordinates2(1,1),ClickCoordinates2(1,2),Distances(1,1);...
                   [pole_length-measure_bottom:5:pole_length].', ClickCoordinates2(2:end,1),ClickCoordinates2(2:end,2), flipud(Distances(2:end))];

% Linearly Interpolate the Lookup Table to make it larger
    interpolated_pixel_lengths=interp1(originaltable(2:end,1),originaltable(2:end,4),pole_length-measure_bottom:0.5:pole_length).';
    x=pole_length-measure_bottom:0.5:pole_length; % create a vector from 5 through the end of the pole length in increments of 0.5
    table=nan(length(interpolated_pixel_lengths)+1,4); % initialize a new table
    table(1,1:4)=originaltable(1,1:4); % Put the 0 length information back into the new table
    
    % Skip to 5 cm and then take the interpolated pixel lengths from after 5 cm and put that in the look up table matrix
        table(2:end,1:4)=[x.', nan(length(pole_length-measure_bottom:0.5:pole_length),2), interpolated_pixel_lengths];
    % Add NaN's to the end of the table so that any erroneous values or
    % images where you cannot see the 
    table(end+1,1:4)=[NaN,NaN,NaN,originaltable(end,4)+(3*((originaltable(end,4)-originaltable(end-1,4))))];

%% Save Data

save(strcat('Empirical_Calibration_for_',site_name,'_Camera_',num2str(camera_number),'_Pole_',num2str(pole_number),num2str(ii)));
end