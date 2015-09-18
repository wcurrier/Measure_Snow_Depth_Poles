% Run this after you have the Snow Depth Data

% To use: After getting snow depth data using
% Loop_through_to_measure_top_and_bottom.m insert the date range from when
% there is no snow to when there is snow again (DO NOT INCLUDE THE DATE
% SNOW APPEARS AGAIN but the last known date when there was no snow) 

% Written by William Currier, currierw@uw.edu
% Sept. 17, 2015

% Fnctions needed: 
%       time_builder.m - Written by Mark Raleigh - http://depts.washington.edu/mtnhydr/people/mraleig1/files/matlab/time_builder.m

%% Code Starts Here

% Load in Snow Depth
load(strcat('Snow_Depth_Data_for_',site_name,'_Camera_',num2str(camera_number),'_Pole_',num2str(pole_number),num2str(ii)));

T = time_builder(yr_i, month_i, day_i, hr_i, min_i, yr_f, month_f, day_f, hr_f, min_f, timestep);

no_snow=zeros(length(T),1);

I=find(T(1,7)==Snow_Depth_time_series(:,7));
Iend=find(T(end,7)==Snow_Depth_time_Series(:,7));

Snow_Depth_time_series(I:Iend,8)=no_snow;

save(strcat('Snow_Depth_Data_filled_w_zeros_for_',site_name,'_Camera_',num2str(camera_number),'_Pole_',num2str(pole_number),num2str(ii)));