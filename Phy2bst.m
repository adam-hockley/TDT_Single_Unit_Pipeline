%% Convert Sorted Phy data back to usable TDT (bst) data
% For TDT data that was prepared for Spike'Interface using StreamToBinary_AH.m
% Uses the sample numbers of where streams were appended to separate them
% again (needs the associated StreamSplitInfo.mat file).
%
% This converts Phy files from SpikeInterface to bst type data to match TDT epochs in BST files.
%
% Step 1 - import phy spike times and clusters and separate spikes
% by which TDT block they were part of.
% Step 2 - Convert Phy spike data to bst format, to make it comparable to
% TDT stimuli.
%
% AH 02/2023

clear
clc

Main_path = 'X:\Researchers\Para Adam\Tanks\';
tanks = {'NPH3','NPH4','NPH5','NPH6','NPH8','NPH9','NPH10'};
Sorter = 'MS5';

%%
for ta = 1:length(tanks)

    % Get electrode positions
    Positions = allfolders([Main_path tanks{ta}]);

    for pos = 1:length(Positions)
        clear PhyRez Spikes_blockSeparated
        tank_path = [Main_path tanks{ta} '\' Positions{pos}];

        % Load file with details from previous combining of block data
        if exist([tank_path '\StreamSplitInfo_All.mat'])
            load([tank_path '\StreamSplitInfo_All.mat'])

            if exist([tank_path '\Sorting\' Sorter '\Phy\spike_times.npy'])

                % Load Kilosort-Phy manual sorting
                clear PhyRez
                PhyRez(:,1) = readNPY([tank_path '\Sorting\' Sorter '\Phy\spike_times.npy']);
                PhyRez(:,2) = readNPY([tank_path '\Sorting\' Sorter '\Phy\spike_clusters.npy']);
                PhyRez(:,2) = PhyRez(:,2)+1; % Remove Phy zero-indexing

                %% Cluster locations (greatest amplitude spike)
                SpikeShapes = readNPY([tank_path '\Sorting\' Sorter '\Phy\templates.npy']); % Spike shapes
                templateindexes = readNPY([tank_path '\Sorting\' Sorter '\Phy\template_ind.npy']); % Spike shapes
                clear bestchannel amp SpikeShapesNew
                newclusters = unique(PhyRez(:,2));

                for i = 1:length(newclusters) % For each cluster
                    for ii = 1:length(SpikeShapes(1,1,:)) % For each channel
                        amp(ii) = peak2peak(SpikeShapes(newclusters(i),:,ii));
                    end
                    maxamps = find(amp == max(amp));
                    bestchannel(i) = templateindexes(i,maxamps(1))+1;

                    SpikeShapesNew(i,:) = SpikeShapes(newclusters(i),:,maxamps(1));
                end
                ClusterGood = [double(newclusters)'; bestchannel];
                save([tank_path '\ClusterGoodLocs.mat'],'ClusterGood','-v7.3')

                disp([tanks{ta} '-' Positions{pos} '-' num2str(length(bestchannel)) ' units'])

                %% Separate spikes by which block they were recorded in

                Ends = cumsum(StreamSplitInfo.LengthSamps); % Get end of block windows
                Start = 1; % Setting initial start sample
                for i = 1:length(StreamSplitInfo.Blocks)

                    curBlockName = StreamSplitInfo.Blocks{i};

                    blockWindow = [Start Ends(i)]; % Get first and last samples of this block
                    Start = Ends(i) + 1; % Setting start sample for next block

                    idx = find(PhyRez(:,1) >= blockWindow(1) & PhyRez(:,1) <= blockWindow(2));
                    Spikes_blockSeparated{i} = PhyRez(idx,:);

                end

                %% For each block, convert to usable data (BST format)
                for i = 1:length(StreamSplitInfo.Blocks) % loop the different blocks

                    % Load BST
                    [bst,~,~] = bbst3(tank_path,StreamSplitInfo.Blocks{i},0); % Load bst (only epochs

                    units = unique(PhyRez(:,2)); % get list of unit numbers from sorted data

                    bst.Spikes = table;
                    SpikesStacked = [];
                    for ii = 1:length(units)
                        % Reduce spikes to just this unit
                        idx = find(Spikes_blockSeparated{i}(:,2) == units(ii));
                        tempSpikes = Spikes_blockSeparated{i}(idx,:);
                        tempSpikes = double(tempSpikes);

                        SpikesStacked = [SpikesStacked; tempSpikes]; %stackem
                    end

                    if i>1 %
                        SpikesStacked(:,1) = SpikesStacked(:,1) - StreamSplitInfo.LengthSamps(i-1);
                    end

                    bst.Spikes.Sample = SpikesStacked(:,1);
                    bst.Spikes.TS = SpikesStacked(:,1) / 24414; % fs hard coded here (actually 24414 as spikeinterface removes the decimal). True sample rate is 24414.0625
                    bst.Spikes.unit = SpikesStacked(:,2); % fs hard coded here

                    % Calculate Trial Index & raster
                    swepoff = bst.Epocs.TSOff.bind;
                    [~,~,bins] = histcounts(bst.Spikes.TS,[bst.Epocs.TSOn.bind; swepoff(end)]);
                    bst.Spikes.TrialIdx = bins;
                    bst.Spikes.TrialIdx(bst.Spikes.TrialIdx==0) = 1;
                    bst.Spikes.RasterSW = bst.Spikes.TS - bst.Epocs.TSOn.bind(bst.Spikes.TrialIdx);

                    bst.SpikeShapes = SpikeShapesNew;

                    save([tank_path '\' StreamSplitInfo.Blocks{i} '\bst_' Sorter '.mat'],'bst')
                    disp(['Block: ' StreamSplitInfo.Blocks{i} '. Units:' num2str(units(ii)) '. Spikes:' num2str(height(bst.Spikes)) '. Saved.'])
                end
            end
        end
    end
end

%%
function folders = allfolders(directory)

folders = dir(directory);
dirFlags = [folders.isdir] & ~strcmp({folders.name},'.') & ~strcmp({folders.name},'..');
folders = folders(dirFlags);
folders = {folders.name};

end
