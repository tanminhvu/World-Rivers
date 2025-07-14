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

load('D:\DL France\NOAA\Ice\read_ice2_next.mat')

x = double(lat);
y = double(lon);
[X,Y] = meshgrid(x,y);
xq = X(:); yq = Y(:);

in = inpolygon(xq,yq,latb,lonb);

%% Plot

c(:,:) = icec(:,:,end);

figure
hold on
contourf(Y',X',c','LineStyle','none')
box on

plot(lonb,latb);
plot(yq(in),xq(in),'r+') % points inside

%% Mean

p=[];

for i = 1:size(icec,3)
    c=[];
    c(:,:) = icec(:,:,i);
    c = c(:);
    p(:,i) = c(in);
end

p_mean = nanmean(p)';

save('read_geo_boundary_ice','p_mean','time','p')