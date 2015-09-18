function [time_series_w_appended_values] = append_to_larger_time_series(time,snow_depth,varargin)

%varargin{1,1}; % column that the data for the smaller time_series is located
%varargin{1,2}; % column that the Matlab Serial Date is located in

%Useful for going from semi-hourly data (time-lapse photos, which were
%taken 5 times a day at various hours) to a complete time_series of hourly
%values with NaN's in between

%snow_depth is the smaller time-series (needs at least MATLAB Serial dates
%and the values you want to append)
%time is the longer time-series (:,7) (time_builder.m format) that you want to append

x=nan(length(time),length(snow_depth)); % initialize a matrix
for ii=1:length(time) % go along the rows after going along each column
    for jj=1:length(snow_depth) % go along each column
        if snow_depth(jj,varargin{1,2})==time(ii,7) % this compares the MATLAB serial dates 
            x(ii,jj)=1; % if they match store a 1 in that column
        end
    end
end
y=nansum(x,2); % there will be many rows that are zero, these are rows 
%where there was no data

count=0; % used to keep track of indicies of the smaller time-series
time_series_w_appended_values=time(:,1:7); %use the time-matrix from the longer time-series to create a new one
time_series_w_appended_values(:,8)=nan(length(time),1); % fill in the eigth column with NaN's
for ii=1:length(y)
    if y(ii)==1
        count=count+1;
        time_series_w_appended_values(ii,8)=snow_depth(count,varargin{1,1}); % this is where it is appended to the longer time_matrix
    end
end
% Output a time_builder matrix with NaN's where there are no values
