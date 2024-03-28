function [bst,superblocks, TDTbin] = bbst3(tank_path,block,RunSpikes)

% BUILD BETTER SPIKE TRAINS YO
% AH2023 - major update to superspiketrain processing (sst, bbst, bbst2 etc).
% Now loading bst directly from TDT tanks, making the superblock within
% this function. Means it only has to do TDTbin2Mat once, much faster, and
% less dependencies.
% BBST3

% Ch - which channel to run, set to 0 to run all.
% Run spikes - 0 to return empty superblock and bst (epochs only)

%% Part 1 - make superblock

if RunSpikes
    TDTbin = TDTbin2mat([tank_path '\' block],'Type',[2 3]);
else
    TDTbin = TDTbin2mat([tank_path '\' block],'Type',[2]);
end

if ~isfield(TDTbin.epocs,'Wfrq')
    error('TDT recording does not contain an epoc called Wfrq. Change code to look for a different TDT epoc name that begins at the start of each sweep')
end

if ~isempty(TDTbin.snips)

    spike_var = fieldnames(TDTbin.snips);
    block = ones(length(TDTbin.snips.(spike_var{1}).chan),1);
    chan = TDTbin.snips.(spike_var{1}).chan;
    ts = TDTbin.snips.(spike_var{1}).ts;
    waves = double(TDTbin.snips.(spike_var{1}).data);
    sortc = zeros(length(TDTbin.snips.(spike_var{1}).chan),1);
    clear BlockIdx
    BlockIdx(1:length(TDTbin.snips.(spike_var{1}).chan),1) = 1;

    partList = unique(TDTbin.epocs.Wfrq.data);
    part = zeros(length(TDTbin.snips.(spike_var{1}).chan),1);
    for i_p = 1:length(partList)
        idx = find(TDTbin.epocs.Wfrq.data==partList(i_p));
        t_start = TDTbin.epocs.Wfrq.onset(idx(1));
        t_end = TDTbin.epocs.Wfrq.offset(idx(end));
        ts_idx = find(TDTbin.snips.(spike_var{1}).ts>=t_start&TDTbin.snips.(spike_var{1}).ts<=t_end);
        part(ts_idx) = partList(i_p);
    end

    SB_com = table(block,BlockIdx,chan,ts,sortc,waves,part);
    SB_com(SB_com.part==0,:) = [];
    epocs = TDTbin.epocs;
else
    SB_com = table([],[],[],[],[],[],'variablenames',...
        {'block','chan','ts','sortc','waves','part'});
end

superblocks = SB_com;


%% Part 2 - make bst epochs
% Get just the spikes for this channel
bst = struct;
bst.tank = tank_path;
bst.Block = block;
bst.EpocNames = {};
bst.Epocs = struct;

if RunSpikes
    bst.channel = unique(TDTbin.snips.eSpk.chan);
end

% % toDelete = superblocks.chan ~= ch;
% toDelete = ~ismember(superblocks.chan, ch);
% superblocks(toDelete,:) = [];
% bst.Spikes = superblocks;

%     epochs = TDT2mat(tank_path,['Block-' num2str(block_list(bl))],'Type',[2],'Verbose',0); % Load epochs
fns = fieldnames(TDTbin.epocs);
nsweps = length(TDTbin.epocs.Wfrq.data);
bst.EpocNames{1} = 'bind';
for ie = 1:length(fns)
    bst.EpocNames{end+1,1} = lower(fns{ie});
end
bst.Epocs.Values = table;
bst.Epocs.TSOn = table;
bst.Epocs.TSOff = table;

h = height(bst.Epocs.Values);
clear blocks bind
%     blocks(1:nsweps) = block_list{bl};
bind(1:nsweps) = 1;

warning off
% Add data values to table
bst.Epocs.Values.Block(h+1:h+nsweps) = {block};
bst.Epocs.Values.bind(h+1:h+nsweps) = bind';
for fi = 1:length(fns)
    tempdata = TDTbin.epocs.(fns{fi}).data;
    bst.Epocs.Values.(lower(fns{fi}))(h+1:h+length(tempdata)) = tempdata;
end

% Add TSOn values to table
bst.Epocs.TSOn.Block(h+1:h+nsweps) = {block};
bst.Epocs.TSOn.bind(h+1:h+nsweps) = TDTbin.epocs.Wfrq.onset(1:nsweps); % 2 to end?
for fi = 1:length(fns)
    tempdata = TDTbin.epocs.(fns{fi}).onset;
    bst.Epocs.TSOn.(lower(fns{fi}))(h+1:h+length(tempdata)) = tempdata;
end

% Add TSoff values to table
bst.Epocs.TSOff.Block(h+1:h+nsweps) = {block};
bst.Epocs.TSOff.bind(h+1:h+nsweps) = TDTbin.epocs.Wfrq.offset(1:nsweps); % 2 to end?
for fi = 1:length(fns)
    tempdata = TDTbin.epocs.(fns{fi}).offset;
    bst.Epocs.TSOff.(lower(fns{fi}))(h+1:h+length(tempdata)) = tempdata;
end
warning on

bst.NTrials = height(bst.Epocs.Values);
bst.Spikes = superblocks;
bst.Spikes.Properties.VariableNames(4) = {'TS'};
bst.Spikes.Properties.VariableNames(5) = {'SortCodes'};

%% Add raster data to bst

if RunSpikes == 1
    % Assign RasterSW timestamps to trials

    % Determine off time in each trial for current block
    swepoff = bst.Epocs.TSOff.bind;

    % Uses histogram counting function to seperate timestamp data into bins
    [~,~,bins] = histcounts(bst.Spikes.TS,[bst.Epocs.TSOn.bind; swepoff(end)]);
    bst.Spikes.TrialIdx = bins;

    % Convert timestamps to rasters
    bst.Spikes.RasterSW = bst.Spikes.TS - bst.Epocs.TSOn.bind(bst.Spikes.TrialIdx);

end
end