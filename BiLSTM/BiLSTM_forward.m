clear
close all
try delete(findall(0))
catch
end

%% Reconstruct h 

load('fill_small_gaps_target.mat')

figure; hold on
plot(normalize(ht))


% Data
hall = [];

load('read_data_precipitation_all.mat')
hall = cat(2,hall,hp);

%load('read_data_soilw200cm_all.mat')
%hall = cat(2,hall,hp);

load('fill_small_gaps_data.mat')
hall = cat(2,hall,ha(:,18 ));

plot(normalize(hall))

%% Select

istart = 620; 
itrain = istart+150;
ivalid = 850;
iend   = 1200;

[htarget,C,S] = normalize(ht(istart:iend,:));
hall = normalize(hall(istart:iend,:));

figure; hold on
plot(htarget)
% plot(hall)

%% Compute

xtrain = hall(1:itrain-istart,:)'  ; ytrain = htarget(1:itrain-istart,:)';
xvalid = hall(itrain-istart+1:ivalid-istart,:)'; yvalid = htarget(itrain-istart+1:ivalid-istart,:)';
xtest = hall(ivalid-istart+1:iend-istart+1,:)'; 

%% Define LSTM Network Architecture

numFeatures = size(xtrain,1);
numResponses = 1;
numHiddenUnits = 15;

layers = [ ...
    sequenceInputLayer(numFeatures)
    bilstmLayer(numHiddenUnits)
    fullyConnectedLayer(numResponses)
    regressionLayer];

options = trainingOptions('adam', ...
    MaxEpochs=250, ...
    ValidationData={xvalid,yvalid}, ...
    ValidationFrequency=25, ...
    Verbose=true, ...
    Plots="training-progress");

net = trainNetwork(xtrain,ytrain,layers,options);

YPred = predict(net,xtest);

% Take values

htarget(ivalid-istart+1:iend-istart+1,1) = YPred';


plot(htarget)

htarget = htarget*S+C; 

[R2,rmse_out] = R2_RMSE_NaN(ht(ivalid:iend,1),htarget(ivalid-istart+1:end,1))

ht(istart:iend,1) = htarget;

% save('test_10a','ht','R2','rmse_out')
