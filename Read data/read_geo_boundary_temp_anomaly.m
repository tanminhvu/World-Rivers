clear
close all

load('read_geo_detail.mat')

lat = lat_basin';
lon = lon_basin';

figure
plot(lon,lat,'Marker','+','LineStyle','none')

%% Boundary

ll = lon + lat; lon(isnan(ll)) = []; lat(isnan(ll)) = [];
k = boundary(lon,lat);

hold on;
plot(lon(k),lat(k));

lonb = lon(k);
latb = lat(k);

%% Find points

load('F:\M2C\D Driver\DL France\NOAA\Temperature anomaly\read_temp_next.mat')

x = double(lat);
y = double(lon);
[X,Y] = meshgrid(x,y);
xq = X(:); yq = Y(:);

in = inpolygon(xq,yq,latb,lonb);

%% Plot

c(:,:) = air(:,:,end);

figure
hold on
contourf(Y',X',c','LineStyle','none')
box on

plot(lonb,latb);
plot(yq(in),xq(in),'r+') % points inside

%% Mean

p=[];

for i = 1:size(air,3)
    c=[];
    c(:,:) = air(:,:,i);
    c = c(:);
    p(:,i) = c(in);
end

p_mean = nanmean(p)';

save('read_geo_boundary_temp_anomaly','p_mean','time','p')