function [Spikes] = BST_GS3(bst,trials,un)

Spikes = bst.Spikes.('RasterSW')(ismember(bst.Spikes.TrialIdx,trials) & bst.Spikes.unit==un );
