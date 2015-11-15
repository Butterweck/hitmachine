function [ r1 r2 ] = ratioOfAccentuation( notes, p )
%ratioOfAccentuation returns r1: ratio of beat velocity
%to max beat velocity (127*numBeats) and r2: ratio
%of beats with velocity less than p to all beats
%   Input:
%           notes: nmat of notes
%           p: threshold for unaccented beats
%   Output:
%           r1: ratio of beat velocity to max beat
%           velocity (127*numBeats)
%           r2: ratio of beats with velocity less than p
%           to #beats
%
if (size(notes,1) == 0)
    r1 = 0;
    r2 = 1;
    return;
end

dur = notes(end, 7);
beat = notes(end, 2);
beatsPerSec = beat/dur;
trackLength = max(notes(:,6) + notes(:,7)); 
nBeats = ceil(beatsPerSec * trackLength);

r1max = nBeats * 127;

idx = find(notes(:,1) == floor(notes(:,1)));
beats = notes(idx,:);
velocities(:,1) = unique(beats(:,1));
% find rows of beats with index x,
% pass them to maxVel to find maximum velocity.
% for x, vector of unique beat times is ran through.
velocities(:,2) = arrayfun(@(x) maxVel(beats(x == beats(:,1),:)), velocities(:,1));

r1 = sum(velocities(:,2))/r1max;
r2 = (length(find(velocities(:,2) < p)) + (nBeats - length(velocities)))/nBeats;

end

function m = maxVel(notes)
[~,idx] = max(notes(:,5));
m = notes(idx,5);
end