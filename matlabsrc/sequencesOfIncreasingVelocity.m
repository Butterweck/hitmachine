function [ nSeq maximum ] = sequencesOfIncreasingVelocity( notes, d, p )
%sequencesOfIncreasingVelocity returns number of
%sequences of increasing velocity and the maximum
%velocity gradient over all sequences
%   Input:
%           notes: nmat
%           d: interval for smoothing velocity curve
%           p: threshold to classify gradients
%           in small and large
%   Output:
%           nSeq: number of sequences
%           maximum: maximum gradient
%
trackLength = max(notes(:,6) + notes(:,7));
gradients = zeros(floor(trackLength/d),1);

% compute vector of gradients
for i = 0 : d : trackLength-d
    gradients(i/d+1) = (grad(seekActiveNotes(i, notes, 'time'), seekActiveNotes(i+d, notes, 'time'), i, i+d));
end

tempSequence = [];
sequences = {};
state = 0;
% find sequences with gradients<p followed by gradients>p
for i = 1 : length(gradients)
    if (gradients(i) <= p && (state == 0 || state == 1))
        tempSequence(end+1) = gradients(i);
        state = 1;
    elseif (gradients(i) > p && (state == 1 || state == 2))
        tempSequence(end+1) = gradients(i);
        state = 2;
    elseif (gradients(i) <= p && state == 2)
        sequences{end+1} = tempSequence;
        tempSequence = [];
        state = 0;
    end
end

% find max gradient
maximum = cellfun(@max, sequences);
maximum = max(maximum);
if (isempty(maximum))
    maximum = 0;
end
% count gradients
nSeq = length(sequences);
end

function g = grad( notesI, notesJ, i, j )
    g = velocity(notesJ, 'max') - velocity(notesI, 'max') / j - i;
end