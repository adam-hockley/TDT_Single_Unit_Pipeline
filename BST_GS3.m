function [Spikes] = BST_GS4(bst,trials,ch)

% temp = bst.Spikes(bst.Spikes.chan==ch,:);
% Spikes = temp.('RasterSW')(ismember(temp.TrialIdx,trials));

Spikes = bst.Spikes.('RasterSW')(ismember(bst.Spikes.TrialIdx,trials) & bst.Spikes.chan==ch );

% testing here
% find(ismember(bst.Spikes.TrialIdx,trials) & bst.Spikes.chan==ch )

