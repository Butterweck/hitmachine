function [ pitch ] = mapToPitchOrig( key, notes )
%mapToPitchOrig returns corresponding tone for key
%in originating octave
%   Input:
%           key: key of notes
%           notes: set of notes (e.g. a chord)
%   Output:
%           pitch: pitch of tone in notes that
%           correspondes to key

notes = notes(:,4);
pitch = -1;

if (key > 12)
    key = key - 12;
end
key = key - 1;

%%%%%%%%%%%%%%%%%%%%
%Key is in notes

%transpose all notes to lowest octave
notesTrans = mod(notes, 12);
%find position of note that corresponds to key
idx = find(notesTrans == key);
if (~isempty(idx))
    pitch = notes(idx);
    %in case two or more notes match
    pitch = max(pitch);
    return;
end

%%%%%%%%%%%%%%%%%%%%
%Key is not in notes

%max 11 octaves in midi data
keyVec = [0 12 24 36 48 60 72 84 96 108 120];
%key tone in all 11 octaves
keyVec = keyVec + key;

%select tone from keyVec with minimal distance to all tones in notes
distances = arrayfun(@(x) distance(x, notes), keyVec);
[~, idx] = min(distances);
if (~isempty(idx))
    pitch = keyVec(idx);
    return;
end

end

function dist = distance( x, vec )
dist = abs(vec - x);
dist = sum(dist);
dist = dist/length(vec);
end
