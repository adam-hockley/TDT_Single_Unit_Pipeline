# TDT single unit analysis pipeline
v1.0
A selection of tools in MATLAB for analysing multi-channel single neuron data recorded using TDT systems. 

The analysis pipeline involves preparing the TDT tank data for sorting, and then re-associating sorted spike data with sitmuli presented during recording. The output is in a proprietary 'bst' format, which is similar to a TDT tank and has custom functions for easy further analysis.

## 1) StreamToBinary_AH.m converts TDT stream data to an i16 binary file. 
This combines any TDT blocks that were recorded on the same neurons, to allow them to be sorted together. The resulting binary file can be easily input to sorting programs. 

In order for looping to work, data folders should be organised as: **AnimalTank/PositionNumber/RecordingBlocks**.

Note: This an adaptation of TDTs own [StreamToBinary](https://www.tdt.com/docs/sdk/offline-data-analysis/offline-data-matlab/export-continuous-data-to-binary-file/) .The updates increase stability for large files and allow appending multiple recording blocks into one binary file. 

Requires TDTBin2Mat from the [TDT Matlab SDK](https://www.tdt.com/docs/sdk/offline-data-analysis/offline-data-matlab/).

BinaryFileCheckPlot.m can be used to load the binary file and plot to confirm it was produced correctly before sorting.

_Then spike sort using SpikeInterface or Kilosort etc and export to Phy format for viewing & manual curation._

## 2) Phy2bst.m converts the sorter output to bst format.
This step turns the output from the spike sorter (in Phy format) back to a format where spike times are associated with stimuli presented during TDT recordings. Data are saved into bst format, as bst.mat in the PositionNumber folder. bst format which is similar in structure to a TDT block recording and has custom functions associated with it that allow easy access to spike times by querying stimulus parameters.

Requires TDTBin2Mat from the [TDT Matlab SDK](https://www.tdt.com/docs/sdk/offline-data-analysis/offline-data-matlab/), [npy-matlab](https://github.com/kwikteam/npy-matlab/tree/master) & bbst3.m.

## 3) Using custom functions to easily access spike data from bst.
The following two functions provide a simple method for querying spike times from the bst formatted data.

### BST_TS3.m
Outputs the stimulus trial numbers corresponding to requested stimulus parameters. e.g. to find stimuli of 10 level and 1 or 2 kHz:

`Trials = BST_TS3(bst,'Lev1',10,'Frq1',[1000 2000])`

### BST_GS3.m
Outputs the spike timings that occurred within the queried trials. e.g. to find spike times for neuron 1 during the trials from above:

`SpikeTimes =  BST_GS3(bst,Trials,1))`
