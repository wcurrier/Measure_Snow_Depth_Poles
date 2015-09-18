clear all; close all; clc
load Snow_Depth_Data_for_Mount_Seattle_West_Camera_1_Pole_2952.mat Snow_Depth_time_series site_name camera_number pole_number pole_length NumberOfCalibrations

load Mount_Seattle_West_Snow_Depth_ZMT_C1P1_400cm_new_calib_2.mat time_series_eye
NumberOfCalibrations=4;
I=find(Snow_Depth_time_series(1,7,1)==time_series_eye(:,7));
Iend=find(Snow_Depth_time_series(end,7,1)==time_series_eye(:,7));

time_series_eye=time_series_eye(I:Iend,:);

diff_between_eye=nan(length(time_series_eye),NumberOfCalibrations);
for jj=1:NumberOfCalibrations
    diff_between_eye(:,jj)=time_series_eye(:,8)-Snow_Depth_time_series(:,8,jj);
    for ii=1:length(diff_between_eye)
        if time_series_eye(ii,8)==0
            diff_between_eye(ii,jj)=NaN;
        end
    end
end

mean_snow_Depth=nanmean(Snow_Depth_time_series(:,8,:),3);

diff_between_eye_and_mean=time_series_eye(:,8)-mean_snow_Depth;
for ii=1:length(diff_between_eye_and_mean)
    if time_series_eye(ii,8)==0
        diff_between_eye_and_mean(ii,1)=NaN;
    end
end


figure(1)

    subplot(3,1,1),plot(Snow_Depth_time_series(:,7),[Snow_Depth_time_series(:,8,1),...
    Snow_Depth_time_series(:,8,2),Snow_Depth_time_series(:,8,3),Snow_Depth_time_series(:,8,4),time_series_eye(:,8)],'o','Linewidth',1),datetick
    legend('Calibration 1','Calibration 2','Calibration 3','Calibration 4','Eye','orientation','horizontal')
    title(strcat(site_name,' Camera ',num2str(camera_number),' Pole ',num2str(pole_number),' , Length =  ',num2str(pole_length(1,1)),' cm '),'Fontsize',20,'fontweight','bold')
    ylabel('Snow Depth [cm]','Fontsize',16,'fontweight','bold')
    xlabel('Month','Fontsize',16,'fontweight','bold')
    set(gca,'Fontsize',14,'fontweight','bold')
    xlim([datenum(2014,10,1),datenum(2015,6,1)])
    
    subplot(3,1,2),plot(Snow_Depth_time_series(:,7),diff_between_eye,'o','Linewidth',1),datetick
    xlim([datenum(2014,10,1),datenum(2015,6,1)])
    title('Snow Depth Differences from Eye and Each Snow Depth from Each Calibration [cm]','Fontsize',18,'fontweight','bold')
    ylabel('Snow Depth Diff [cm]','Fontsize',16,'fontweight','bold')
    xlabel('Month','Fontsize',16,'fontweight','bold')
    legend('Calibration 1','Calibration 2','Calibration 3','Calibration 4','Eye','orientation','horizontal')
    set(gca,'Fontsize',14,'fontweight','bold')
    
    subplot(3,1,3),plot(Snow_Depth_time_series(:,7),diff_between_eye_and_mean,'o','Linewidth',1),datetick
    xlim([datenum(2014,10,1),datenum(2015,6,1)])
    title('Snow Depth Differences from Eye and Mean Snow Depth [cm]','Fontsize',18,'fontweight','bold')
    ylabel('Snow Depth Diff [cm]','Fontsize',16,'fontweight','bold')
    xlabel('Month','Fontsize',16,'fontweight','bold')
    legend('Mean Calibrations','orientation','horizontal')
    set(gca,'Fontsize',14,'fontweight','bold')