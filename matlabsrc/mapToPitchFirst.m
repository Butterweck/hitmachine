function [ pitch, majOrMin ] = mapToPitchFirst( key )
%mapToPitchFirst returns corresponding tone 
%for key in first octave [0 .. 12]
%and 'major' or 'minor'
%   Input:
%           key:        key of notes
%   Output:
%           pitch:      pitch of tone in notes that
%                       correspondes to key
%           majOrMin:   major or minor?
%   

majOrMin = 'major';

if (key > 12)
    key = key - 12;
    majOrMin = 'minor';
end
key = key - 1;

pitch = key;

end

