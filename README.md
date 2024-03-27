# Adam Hockley's TDT analysis pipeline
A selection of tools in MATLAB for analysing multi-channel single neuron data recorded using TDT systems. 
The analysis pipeline involves the following steps:

## 1) StreamToBinary_AH.m converts TDT stream data to an i16 binary file. 
This combines any TDT blocks that were recorded on the same neurons, to allow them to be sorted together. The resulting binary file can be easily input to sorting programs.  
Requires TDTBin2Mat from the [TDT Matlab SDK](https://www.tdt.com/docs/sdk/offline-data-analysis/offline-data-matlab/).
N.B. This an adaptation of TDTs own [StreamToBinary](https://www.tdt.com/docs/sdk/offline-data-analysis/offline-data-matlab/export-continuous-data-to-binary-file/) the updates made make increase stability for large files and allow appending multiple recording blocks into one binary file.

_Then sort using SpikeInterface or Kilosort etc and export to Phy format for viewing & manual curation._

## 2) Phy2bst.m converts the sorter output (in Phy format) to bst format.
This step turns the output from the spike sorter back to a format where spike times are associated with stimuli presented during TDT recordings. Data are saved into a bst format that is similar in structure to a TDT block recording, but has 

## 3) Using custom functions to easily access data form bst data format
### BST_GS
### BST_TS
