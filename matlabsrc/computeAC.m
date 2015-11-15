function [ ac ] = computeAC( notes, step, timeSigNum)
%computeD returns distance index of nmat notes
%   Input:
%           notes: notematrix
%           step: vector of numbers of bars to shift
%           timeSigNum: numerator of time signature
%           (= beats per bar)
%   Output:
%           ac: autocorrelation
%
ac = zeros(length(step),1);
cov = zeros(length(step),1);

dur = notes(end, 7);
beat = notes(end, 2);
beatsPerSec = beat/dur;
SecPerBeat = dur/beat;
trackLength = max(notes(:,6) + notes(:,7)); 
nBeats = beatsPerSec * trackLength;

nBars = nBeats / timeSigNum;
m = SecPerBeat/2;

% segment notes in m intervals
c = cache(notes, m);

% convert vector of notes into vector of intervals
g = @(x,y) abs(x-y);
c = arrayfun(@(x) similarity(c(x),c(x+1),g), 1:length(c)-1);

% autocovariance matrix
avg = sum(c)/length(c);
f = @(x,y) (x - avg)*(y - avg);
mat = computeMatrix(c, f);

var = sum((c - avg).^2)/(length(c)-1);

nIntervals = size(mat, 1);
b = ceil(nIntervals/nBars);

% function handle for accesing mat at column j 
% and corresponding row for computing autocorrelation
p = @(j,s) mat(mod(j + b*s - 1, nIntervals) + 1, j);

% compute an autocorrelation for every given step
for count = 1 : length(step)
    coefficients = arrayfun(@(j) p(j, step(count)), 1 : nIntervals);
    cov(count) = sum(coefficients)/(nIntervals - 1);
    ac(count) = cov(count) / var;
end

ac = ac';

end