clear
close all
try delete(findall(0))
catch
end

%% Reconstruct h 

load('fill_small_gaps_target.mat')
ht = flip(ht,1);

figure; hold on
plot(normalize(ht))


% Data
hall = [];

load('read_data_precipitation_v401_all.mat')
hp = flip(hp,1);
hall = cat(2,hall,hp);

load('fill_small_gaps_data.mat')
hp = flip(ha(:,3),1);

hall = cat(2,hall,hp);

plot(normalize(hall))

%% Select

istart = 750; 
itrain = istart+150;
ivalid = 930;
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
numHiddenUnits = 20;

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
grid on

htarget = htarget*S+C; 

[R2,rmse_out] = R2_RMSE_NaN(ht(ivalid:iend,1),htarget(ivalid-istart+1:end,1))

ht(istart:iend,1) = htarget;

ht = flip(ht,1);

% save('test_11a','ht','R2','rmse_out')