% Run this after the Empirical Calibration Script

% Zoomed in Measure Tool: Written by William Currier, currierw@uw.edu
% August 20, 2015
% This script is designed to measure snow pole images by calibrating to the
% entire pole and using the look up table

% Instructions --> Run File
    % 1. Change the start image and end image appropriately, also update
    % the path
    % 2. Make a bounding box around the bottom part of the pole, leave enough
    % room for camera movement, the script isn't designed to adjust the zoom in
    % once you draw the bounding box
    % 3. Click at the bottom part of the pole on the left most image
    % subplot(1,2,1) for every image
    % 4. Make a bounding box around the top part of the pole, leave enough
    % room for camera movement, the script isn't designed to adjust the zoom in
    % once you draw the bounding box
    % 5. Click at the top part of the pole on the left most image
    % subplot(1,2,1) for every image


% Note: If you cannot see an image due to condensation on the camera
% lens or just poor lighting than you can click on the bottom left part of
% the gray window while you're looking at the bottom of the pole and the
% top left part of the gray window while looking at the top of the pole.

% Fnctions needed: 
%       time_builder.m - Written by Mark Raleigh - http://depts.washington.edu/mtnhydr/people/mraleig1/files/matlab/time_builder.m
%       append_to_larger_time_series.m - Written by William Currier, currierw@uw.edu
%       look_up_table.m - Written by William Currier, currierw@uw.edu
%% Adjust these parameters accordingly before looping through

% Load in the Calibration Data
load('Empirical_Calibration_for_Mount_Seattle_West_Camera_1_Pole_21.mat')
% load(strcat('Empirical_Calibration_for_',site_name,'_Camera_',num2str(camera_number),'_Pole_',num2str(pole_number),1));
NumberOfCalibrations=length(Image_Number);
numImgs = size(listing,1); % determines the number of images in the directory you pointed to

% Say you don't want to start clicking on images in september, jump XXX
% (e.g. 100) ahead by changing startimage
startimage=200;
endimage=1028;

timestamp=1;
% 1 means that you're looking at a timestamp that is in the image, for
% instance, if it is a cropped image, the time-stamp is in the title
%% Loop through to get all of the bottom Points and their coordinates

% StoredCoordinatesBotoom{1,:}={'Bottom Coordinates From Clicking, X and Y','min x','max x','min y','max y','date','full file name'};
count=1;
for i=startimage:endimage %should be to numImgs
    
    originalImage = imread(listing(i).name);
    nextoriginalImage = imread(listing(i+1).name);
    
            if i==startimage
                imshow(originalImage)
                [X,Y]         = ginput(4);
            end
            
    figure(1)
    % If statement changes on how it stores the timestamps assosciated with each picture
    subplot(1,2,1),imshow(originalImage(min(Y):max(Y),min(X):max(X),:),'InitialMagnification', 400)
        if timestamp==1
            title(listing(i).name(length(listing(i).name)-22:length(listing(i).name)-10))
        end
    subplot(1,2,2),imshow(nextoriginalImage(min(Y):max(Y),min(X):max(X),:),'InitialMagnification', 400)
        if timestamp==1
            title(listing(i+1).name(length(listing(i+1).name)-22:length(listing(i+1).name)-10))
        end
   
    [BottomCoordinates]         = ginput(1);
    % If statement changes on how it stores the timestamps assosciated with each picture
    if timestamp==1;
        StoredCoordinatesBottom{count,:} = {BottomCoordinates, min(X),max(X), min(Y), max(Y) , min(X)+BottomCoordinates(1,1),min(Y)+ BottomCoordinates(1,2), listing(i).name(length(listing(i).name)-22:length(listing(i).name)-10), listing(i).name};
    end
    count=count+1;
end

close all


%% Loop Through and get all of the Top Coordinates
clear X Y
count=1;
for i=startimage:endimage %should be to numImgs
    
    originalImage = imread(listing(i).name);
    nextoriginalImage = imread(listing(i+1).name);

            if i==startimage
                imshow(originalImage)
                [X,Y]         = ginput(4);
            end
            
    figure(1)
    subplot(1,2,1),imshow(originalImage(min(Y):max(Y),min(X):max(X),:),'InitialMagnification', 400)
        if timestamp==1
            title(listing(i).name(length(listing(i).name)-22:length(listing(i).name)-10))
        end
    subplot(1,2,2),imshow(nextoriginalImage(min(Y):max(Y),min(X):max(X),:),'InitialMagnification', 400)
        if timestamp==1
            title(listing(i+1).name(length(listing(i+1).name)-22:length(listing(i+1).name)-10))
        end

   
    [TopCoordinates]         = ginput(1);
    
    if timestamp==1
        StoredCoordinatesTop{count,:} = {TopCoordinates, min(X),max(X), min(Y), max(Y) , min(X)+TopCoordinates(1,1),min(Y)+ TopCoordinates(1,2), listing(i).name(length(listing(i).name)-22:length(listing(i).name)-10), listing(i).name};
    end
    count=count+1;
end


%% Compute Pixel Distances and Track Time
close all;

% Initialize Matrices for speed
Year_double=nan(length(StoredCoordinatesBottom),1); Month_double=nan(length(StoredCoordinatesBottom),1); Day_double=nan(length(StoredCoordinatesBottom),1); Hour_double=nan(length(StoredCoordinatesBottom),1); PixelDistances=nan(length(StoredCoordinatesBottom),1);
for ii=1:length(StoredCoordinatesBottom)

        FullBottomX=StoredCoordinatesBottom{ii,1}{1,6}(1,1); % Bottom X coordinate of full image after calibration
        FullTopX=StoredCoordinatesTop{ii,1}{1,6}(1,1); % Top X coordinate of full image after calibration
        FullTopY=StoredCoordinatesTop{ii,1}{1,7}(1,1); % Top Y coordinate of full image after calibration
        FullBottomY=StoredCoordinatesBottom{ii,1}{1,7}(1,1); % Bottom Y coordinate of full image after calibration
        
        % Pixel Distances
        if StoredCoordinatesBottom{ii,1}{1,1}(1,1)<0 || StoredCoordinatesTop{ii,1}{1,1}(1,1)<0
            PixelDistances(ii,1)=NaN;
        else
            PixelDistances(ii,1) = (sqrt((FullTopX-FullBottomX)^2+(FullTopY-FullBottomY)^2)); % This caluclates the snow depth based on the pole length and the length per pixel multiplied by the distance between the coordinates
        end
        
%         Year_double(ii,:)=str2double(char(StoredCoordinatesBottom{ii,1}{1,8}(1:4)));
%         Month_double(ii,:)=str2double(char(StoredCoordinatesBottom{ii,1}{1,8}(6:7)));
%         Day_double(ii,:)=str2double(char(StoredCoordinatesBottom{ii,1}{1,8}(9:10)));
%         Hour_double(ii,:)=str2double(char(StoredCoordinatesBottom{ii,1}{1,8}(12:13)));
        
        Year_double(ii,:)=str2num(datestr(datenum(StoredCoordinatesBottom{ii,1}{1,8}(1:length(StoredCoordinatesBottom{ii,1}{1,8})-3)),'yyyy'));
        Month_double(ii,:)=str2num(datestr(datenum(StoredCoordinatesBottom{ii,1}{1,8}(1:length(StoredCoordinatesBottom{ii,1}{1,8})-3)),'mm'));
        Day_double(ii,:)=str2num(datestr(datenum(StoredCoordinatesBottom{ii,1}{1,8}(1:length(StoredCoordinatesBottom{ii,1}{1,8})-3)),'dd'));
        Hour_double(ii,:)=str2num(datestr(datenum(StoredCoordinatesBottom{ii,1}{1,8}(1:length(StoredCoordinatesBottom{ii,1}{1,8})-3)),'HH'));
end

%% Use lookup table to determine the Snow Depth from the caluclated distances

for jj=1:NumberOfCalbrations;
    load(strcat('Empirical_Calibration_for_',site_name,'_Camera_',num2str(camera_number),'_Pole_',num2str(pole_number),num2str(jj)));
    clear output_index

    
        output_index=look_up_table(PixelDistances.',table(:,4).');  %find the closest index of PixelDistances to the look up table distance and outputs that index

        for ii=1:length(PixelDistances)
             Snow_Depth(ii,1,jj)=pole_length-table(output_index(ii),1);
             Snow_Depth(ii,2,jj)=datenum(Year_double(ii),Month_double(ii),Day_double(ii),Hour_double(ii),0,0);
        end
        
        for ii=1:length(PixelDistances)
            if ii>1
                if Snow_Depth(ii-1,1,jj)-Snow_Depth(ii,1,jj) > 8 && Snow_Depth(ii+1,1,jj)-Snow_Depth(ii,1,jj)>-8
                    Snow_Depth(ii,1,jj)=NaN;
                end
            end
        end
        
        
end
%% Get the Data to look nice in a time-series!

% Get an entire time-builder matrix
    Snow_Depth_time_series=time_builder(Year_double(1,1),Month_double(1,1),Day_double(1,1),Hour_double(1,1),0,Year_double(end,1),Month_double(end,1),Day_double(end,1),Hour_double(end,1),0,1);

% append the measurements to the time series accordingly
for jj=1:NumberOfCalbrations;
    Snow_Depth_time_series(:,1:8,jj) = append_to_larger_time_series(Snow_Depth_time_series,Snow_Depth(:,:,jj),1,2);
% Snow Depth values are located in column 1
% Matlab Serial Dates are located in column 2
end

figure(1)
    plot(Snow_Depth_time_series(:,7),[Snow_Depth_time_series(:,8,1),...
        Snow_Depth_time_series(:,8,2),Snow_Depth_time_series(:,8,3),Snow_Depth_time_series(:,8,4)],'o'),dynamicDateTicks
    legend('Calibration 1','Calibration 2','Calibration 3','Calibration 4')
    title(strcat(site_name,' Camera ',num2str(camera_number),' Pole ',num2str(pole_number),' , Length =  ',num2str(pole_length(1,1)),' cm '),'Fontsize',16)
    ylabel('Snow Depth [cm]','Fontsize',16)
    xlabel('Month','Fontsize',16)


save(strcat('Snow_Depth_Data_for_',site_name,'_Camera_',num2str(camera_number),'_Pole_',num2str(pole_number),num2str(ii)));