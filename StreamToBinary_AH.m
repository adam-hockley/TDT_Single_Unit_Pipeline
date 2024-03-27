% Export Continuous Data To Binary File
% Edited from TDT's supplied file 'StreamToBinary' to allow production of a
% single binary file from multiple TDT recording blocks.
%
% Outputs a .i16 file for conversion to bin and input to kilosort. Also
% outputs a StreamSplitInfo_*.mat file detailing how many samples were from
% each block. This is used later by rez2TDT to separate the blocks again.
%
%  Requires TDTbin2mat and matlab SDK in matlab path
%
% AH 02/2023

tic
%% All variables to change in here
close all; clear all; clc;
TANKPATH = '\\anlserver.der.usal.es\Shared\Researchers\Para Adam\Tanks\TestTank';

%% Get electrode positions

Positions = allfolders(TANKPATH);

for pos = 1:length(Positions)

    disp(['Running pos ' num2str(pos) ' of ' num2str(length(Positions))])
    DATAPATH = [TANKPATH '\' Positions{pos}];
    SAVEPATH = DATAPATH;
    OutFileName = num2str(Positions{pos});

   Positions = allfolders(DATAPATH);
    
    % Or set blocks manually
%     Blocks = {'3-1-FRA'};

    % Set the variables for the data you want to extract from all blocks
    FORMAT = 'i16'; % i16 = 16-bit integer, f32 = 32-bit floating point
    SCALE_FACTOR = 1e6; % scale factor for 16-bit integer conversion, so units are uV
    OUTFILE = fullfile(SAVEPATH, [OutFileName '.' FORMAT]);

    StreamSplitInfo = struct;
    StreamSplitInfo.Blocks = Blocks;

    for i = 1:length(Blocks) % For all blocks that need appending to the original binary file

        % Set variables for blocks to append (2,3,4 etc)
        BLOCKPATH = fullfile(DATAPATH,Blocks{i});
%         data = TDTbin2mat(BLOCKPATH, 'TYPE', {'streams'}, 'T2', 1); % read the first second of data to get the channel coun
        data = TDTbin2mat(BLOCKPATH, 'TYPE', [4], 'T2', 1); % read the first second of data to get the channel coun

        store = fields(data.streams);
        thisStore = store{1};

        TIME_DELTA = 10;
        T1 = 0;
        T2 = T1 + TIME_DELTA;

        if i == 1
            fid = fopen(OUTFILE, 'wb');
        else
            fid = fopen(OUTFILE, 'a');
        end

        data = TDTbin2mat(BLOCKPATH, 'STORE', store);
        nsecs = length(data.streams.SU_2.data)/data.streams.SU_2.fs;
        StreamSplitInfo.LengthSamps(i) = length(data.streams.SU_2.data);
        fs = data.streams.(thisStore).fs;
        nchan = size(data.streams.(thisStore).data,1);

        data = TDTbin2mat(BLOCKPATH, 'STORE', store, 'T1', T1, 'T2', T2);

        % Only use first 32ch for NPH9
%         data.streams.SU_2.data = data.streams.SU_2.data(1:32,:);

        % loop through data in 10 second increments
        while T1<nsecs
            if strcmpi(FORMAT, 'i16')
                fwrite(fid, SCALE_FACTOR*reshape(data.streams.(thisStore).data, 1, []), 'integer*2');
            elseif strcmpi(FORMAT, 'f32')
                fwrite(fid, SCALE_FACTOR*reshape(data.streams.(thisStore).data, 1, []), 'single');
            else
                warning('Format %s not recognized. Use i16 or f32', FORMAT);
                break
            end
            T1 = T2;
            T2 = T2 + TIME_DELTA;
            data = TDTbin2mat(BLOCKPATH, 'STORE', store, 'T1', T1, 'T2', T2);

            % Only use first 32ch for NPH9
%             data.streams.SU_2.data = data.streams.SU_2.data(1:32,:);
        
        end
        fprintf('Wrote %s to output file %s\n', thisStore, OUTFILE);
        fprintf('Sampling Rate: %.6f Hz\n', fs);
        fprintf('Num Channels: %d\n', nchan);
        fclose(fid);
    end
    if i > 1 
%         save(string([SAVEPATH '\StreamSplitInfo_' OutFileName '.mat']),'StreamSplitInfo')
        save(string([SAVEPATH '\StreamSplitInfo_All.mat']),'StreamSplitInfo')
    end

end
toc