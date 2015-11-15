function [ sequence ] = sequentialize( notes, mode )
%sequentialize turn an nmat notes into a vector
%of sequentialized intervals
%   Input:
%           notes:      nmat
%           mode:       'first' to map all chord keys
%                       (as result of kkkey)
%                       to lowest octave,
%                       'orig' to map them to
%                       their originating octave
%   Output:
%           sequence:   interval vector

% get vector of start and ent times of all notes
times = [notes(:,6)' (notes(:,6)+notes(:,7))'];
times = sort(times);
times = unique(times);

% handle for mapping active notes at x to key in first octave
if (strcmp(mode, 'first'))
    map = @(x) mapToPitchFirst(kkkey(seekActiveNotes(x, notes, 'time')));
elseif (strcmp(mode, 'orig'))
    map = @(x) mapToPitchOrig(kkkey(seekActiveNotes(x, notes, 'time')), seekActiveNotes(x, notes, 'time'));
end
    
% handle for testing if no note is playing at x (return NaN then)
test = @(x) iff(~isempty(seekActiveNotes(x, notes, 'time')), map, x);

% sequentialize and delete all NaNs
sequence = arrayfun(@(x) test(x), times);
sequence = sequence(~isnan(sequence));
end

function res = iff(cond, handle, arg)
    if cond
        res = handle(arg);
    else
        res = [ NaN ];
    end
end
