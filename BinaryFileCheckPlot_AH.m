% Loads in a binary file (created by StreamToBinary_AH.m) and checks the data by plotting some streams 
% AH 02/2023
% 
nChan = 32; % has to be correct because binary file data is interleaved.
fid = fopen('binaryfilelocation\1.bin','r');
dat = fread(fid,[nChan inf],'*int16');
fclose(fid);
% plot(dat(:,1:50000)'+(1:size(dat,1))*1000);


%%    
plotlength = 24414*20;
[b] = fir1(128,[300 5000]/(24414/2)); % fs hard coded here
figure
for i = 1:length(dat(:,1)) % Only plotting channel 1 at the moment
    plotdat = double(dat(i,1:plotlength));
    plotdat = filtfilt(b,1,plotdat);
    timevector = (1:length(plotdat))/24414;
    plot(timevector,(plotdat+(i*300))/1000)
    hold on

end

% exportgraphics(gcf,'SaveLoc.eps')% x = imresize(x,0.4811161);
% close all

%%    
figure
fs = 24414.025;
plotlength = fs*10;
% start = 3*fs;
start = 8189952;
plotdat = double(dat(25,start:start+plotlength));

[b] = fir1(128,[300 5000]/(fs/2));
plotdatsu = filtfilt(b,1,plotdat);
timevector = (1:length(plotdatsu))/fs;
plot(timevector,(plotdatsu/1000))

hold on

[b] = fir1(128,[1 200]/(fs/2));
plotdatmu = filtfilt(b,1,plotdat);
timevector = (1:length(plotdatmu))/fs;
plot(timevector,(plotdatmu/10000),'k','linewidth',2)

    
