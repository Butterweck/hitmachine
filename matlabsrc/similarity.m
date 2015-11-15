function [ sim ] = similarity( g, h, f )
%similarity computes similarity of two notes or chords
%   Input:
%            g: note or chord (row(s) of nmat)
%            h: note or chord (row(s) of nmat)
%            f: elementary similarity function for two notes
%   Output:
%            sim: similarity measure

sim = 0;

if (size(g,1) ~= 1)
    g = mapToPitchOrig(kkkey(g), g);
end
if (size(h,1) ~= 1)
    h = mapToPitchOrig(kkkey(h), h);
end

sim = f(g,h);

end