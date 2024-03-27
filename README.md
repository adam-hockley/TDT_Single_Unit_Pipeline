A selection of tools for analysing multi-channel single neuron data recorded using TDT systems.

The pipeline involves a few steps:

1) StreamToBinary_AH converts TDT stream data to an i16 binay file. This combines any TDT blocks that were recorded on the same neurons, to allow sorting together. This binary file can then easily be input to SpikeInterface or Kilosort for sorting.

2) 

