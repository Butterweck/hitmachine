function [ freq ] = kSequences( notes, k )
%kSequences returns a map that indicates the frequency
%of all sequences of k intervals in nmat notes
%   Input:
%           notes:  nmat
%           k:      length of sequences
%   Output:
%           freq:   map that indicates the
%                   frequency of k-sequences 

freq = containers.Map('KeyType','char','ValueType','int32');

notes = sequentialize(notes, 'first');
intervals = zeros(length(notes)-1);

% convert notevector into vector of intervals
for i = 1 : length(notes)-1
    intervals(i) = abs(notes(i)-notes(i+1));
end

% get all k-sequences and update their freuquency in map freq
for i = 1 : length(intervals)-(k-1)
    sequence = intervals(i:i+k-1);
    seqName = toString(sequence);
    if (isKey(freq, seqName))
        freq(seqName) = freq(seqName) + 1;
    else
        freq(seqName) = 1;
    end
end

end

% converts sequence into a key name
function name = toString( pitches )
    name = '';

    for i = 1 : length(pitches)
        name = [name int2str(pitches(i))];
        if ~(i == length(pitches))
            name = [name '|'];
        end
    end
end