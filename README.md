# Adam Hockley's TDT analysis pipeline
A selection of tools in MATLAB for analysing multi-channel single neuron data recorded using TDT systems. 

To-do list:
- [ ] Check all required functions are also in the repository
- [ ] Check bst function examples
- [ ] Check bst Wfrq is not hard coded throughout, maybe could use a different trial idx. Especially in bbst3

The analysis pipeline involves the following steps:

## 1) StreamToBinary_AH.m converts TDT stream data to an i16 binary file. 
This combines any TDT blocks that were recorded on the same neurons, to allow them to be sorted together. The resulting binary file can be easily input to sorting programs.  

N.B. This an adaptation of TDTs own [StreamToBinary](https://www.tdt.com/docs/sdk/offline-data-analysis/offline-data-matlab/export-continuous-data-to-binary-file/) the updates made make increase stability for large files and allow appending multiple recording blocks into one binary file. 

Requires TDTBin2Mat from the [TDT Matlab SDK](https://www.tdt.com/docs/sdk/offline-data-analysis/offline-data-matlab/).

_Then spike sort using SpikeInterface or Kilosort etc and export to Phy format for viewing & manual curation._

## 2) Phy2bst.m converts the sorter output to bst format.
This step turns the output from the spike sorter (in Phy format) back to a format where spike times are associated with stimuli presented during TDT recordings. Data are saved into bst format, which is similar in structure to a TDT block recording but has custom functions associated with it that allow easy access to spike times by querying stimulus parameters.

Requires [npy-matlab](https://github.com/kwikteam/npy-matlab/tree/master).

## 3) Using custom functions to easily access data from bst data format
### BST_TS 
Outputs the stimulus trial numbers corresponding to requested stimulus parameters. e.g. to find stimuli of 10 level and 1 or 2 kHz:

`Trials = BST_TS(bst,'Lev1',10,'Frq1',[1000 2000])`

### BST_GS
Outputs the spike timings that occurred within the queried trials. e.g. to find spike time during the trials from above:
`SpikeTimes = BST_GS(bst,'Lev1',10,'Frq1',[1000 2000])`
