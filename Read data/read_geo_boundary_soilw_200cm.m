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

load('D:\DL France\NOAA\Soil Moisture\read_soilw_200cm_next.mat')

x = double(lat);
y = double(lon);
[X,Y] = meshgrid(x,y);
xq = X(:); yq = Y(:);

in = inpolygon(xq,yq,latb,lonb);

%% Plot

c(:,:) = soilw(:,:,end);

figure
hold on
contourf(Y',X',c','LineStyle','none')
box on

plot(lonb,latb);
plot(yq(in),xq(in),'r+') % points inside

%% Mean

w=[];

for i = 1:size(soilw,3)
    c=[];
    c(:,:) = soilw(:,:,i);
    c = c(:);
    w(:,i) = c(in);
end

w_mean = nanmean(w,1)';

save('read_geo_boundary_soilw_200cm','w_mean','time','w')