function [ M attrNames ] = getFeatureVectors( file )
%getFeatureVectors returns matrix M of samples in rows
%and features in columns
%
%Input:
%   file: path to index file structured as follows
%
%         every line is a song:
%                   
%         path to txt file; entrance chart position;
%         peak chart position; 
%         midi channels containing melody tracks (sep. by,);
%         midi channels containing harmony tracks (sep. by,);
%         midi channels containing rhythm tracks (sep. by,)
%
%         use mf2txt.exe to generate txt files
%
%         example: Paint_it_Black.txt;5;1;12,5;4,8,3;10
%Output:
%   M: matrix of samples in rows and features in columns
%   attrNames: cell array containing column of M as key
%              and name of attribute as value

% time capturing
begin = tic;
fprintf('Starting ...\n');

[name entrance peak mel harm rhyth] = textread(file, '%s %d %d %s %s %s','delimiter',';');

mel = cellfun(@(x) strsplit(x,','), mel, 'UniformOutput', false);
harm = cellfun(@(x) strsplit(x,','), harm, 'UniformOutput', false);
rhyth = cellfun(@(x) strsplit(x,','), rhyth, 'UniformOutput', false);

mel = cellfun(@(x) cellfun(@(y) str2num(y),x), mel, 'UniformOutput', false);
harm = cellfun(@(x) cellfun(@(y) str2num(y),x), harm, 'UniformOutput', false);
rhyth = cellfun(@(x) cellfun(@(y) str2num(y),x), rhyth, 'UniformOutput', false);

% matrix with samples in rows and features in columns
M = zeros(length(name),1);
M(:,1) = 1:length(name);
attrNames = cell(0,0);
attrNames{1} = 'id';

% cell array of maps to store k-sequences temporarily
% during iteration over samples
freq = cell(length(name),0);
for i = 1 : length(name)
    freq{i} = containers.Map('KeyType','char','ValueType','int32');
end

for i = 1 : length(name)
    songBegin = tic;
    nmat = mftxt2nmat(name{i});
    m = drop(nmat, [harm{i} rhyth{i}]);
    h = drop(nmat, [mel{i} rhyth{i}]);
    hm = drop(nmat, [rhyth{i}]);
    r = drop(nmat, [harm{i} mel{i}]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % AC & D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [avg_m, s2_m] = computeD(m, [1 2 4 8 16 32], 4);
    [avg_h, s2_h] = computeD(h, [1 2 4 8 16 32], 4);
    M(i,2:25) = [avg_m avg_h s2_m s2_h];
    M(i,26:31) = computeAC(m, [1 2 4 8 16 32], 4);
    M(i,32:37) = computeAC(h, [1 2 4 8 16 32], 4);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ratio of accentuation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    p = 50 : 5 : 70;
    [r1_r r2_r] = arrayfun(@(x) ratioOfAccentuation(r, x), p);
    [r1_hm r2_hm] = arrayfun(@(x) ratioOfAccentuation(hm, x), p);
    M(i,38:47) = [r1_r r1_hm];
    M(i,48:57) = [r2_r r2_hm];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % sequences of increasing velocity
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    p = 40 : 5 : 200;
    [n max] = arrayfun(@(x) sequencesOfIncreasingVelocity(nmat, 0.5, x), p);
    M(i,58:90) = n;
    M(i,91:123) = max;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % melody
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    p = [1/16 1/8 1/4];
    [v rMax rMin rL] = arrayfun(@(x) melody(m, x), p);
    M(i,124:135) = [v rMax rMin rL];
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ratio of scalic notes
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    M(i,136) = ratioOfScalicNotes( nmat );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % key points
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rKP = keyPointsFromVelocity( r, 4, 0.5 );
    hmKP = keyPointsFromVelocity( hm, 4, 0.5 );
    keyP = unique([rKP hmKP]);
    [ratio int] = attributesFromVelocityKeyPoints(keyP, hm);
    M(i,137) = ratio;
    M(i,138:140) = int;
    
    p = [ 4 5 6 7 ];
    ratio = arrayfun(@(x) attributesFromIntervalKeyPoints(m, x), p);
    M(i,141:144) = ratio;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % k-sequences
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    f = kSequences(h, 2);
    freq{i} = joinMaps(freq{i}, f);
    f = kSequences(h, 3);
    freq{i} = joinMaps(freq{i}, f);
    f = kSequences(h, 4);
    freq{i} = joinMaps(freq{i}, f);
    f = kSequences(m, 2);
    freq{i} = joinMaps(freq{i}, f);
    f = kSequences(m, 3);
    freq{i} = joinMaps(freq{i}, f);
    f = kSequences(m, 4);
    freq{i} = joinMaps(freq{i}, f);
    
    fprintf('Song %d done. Took %f seconds.\n', i, toc(songBegin));
end

% map k-seq names to columns of M
freqToM = containers.Map('KeyType','char','ValueType','int32');
start = 145;
for i = 1 : length(freq)
    allKeys = keys(freq{i});
    for j = 1 : length(allKeys)
        k = allKeys{j};
        if (~isKey(freqToM, k))
            freqToM(k) = start;
            start = start + 1;
        end
    end
end

% transfer particular freq{i}'s to M
allKeys = keys(freqToM);
for i = 1 : length(allKeys)
    k = allKeys{i};
    for j = 1 : length(name)
        if (isKey(freq{j}, k))
            M(j, freqToM(k)) = freq{j}(k);
        else
            M(j, freqToM(k)) = 0;
        end
    end    
end

% label
M(:,end+1) = entrance;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% attribute names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
attrNames(2:7) = [{'D_avg_m_1'},{'D_avg_m_2'},{'D_avg_m_4'},{'D_avg_m_8'},{'D_avg_m_16'},{'D_avg_m_32'}];
attrNames(8:13) = [{'D_avg_h_1'},{'D_avg_h_2'},{'D_avg_h_4'},{'D_avg_h_8'},{'D_avg_h_16'},{'D_avg_h_32'}];
attrNames(14:19) = [{'D_s2_m_1'},{'D_s2_m_2'},{'D_s2_m_4'},{'D_s2_m_8'},{'D_s2_m_16'},{'D_s2_m_32'}];
attrNames(20:25) = [{'D_s2_h_1'},{'D_s2_h_2'},{'D_s2_h_4'},{'D_s2_h_8'},{'D_s2_h_16'},{'D_s2_h_32'}];
attrNames(26:31) = [{'AC_m_1'},{'AC_m_2'},{'AC_m_4'},{'AC_m_8'},{'AC_m_16'},{'AC_m_32'}];
attrNames(32:37) = [{'AC_h_1'},{'AC_h_2'},{'AC_h_4'},{'AC_h_8'},{'AC_h_16'},{'AC_h_32'}];
attrNames(38:42) = [{'rOA_1_r_50'},{'rOA_1_r_55'},{'rOA_1_r_60'},{'rOA_1_r_65'},{'rOA_1_r_70'}]; 
attrNames(43:47) = [{'rOA_1_hm_50'},{'rOA_1_hm_55'},{'rOA_1_hm_60'},{'rOA_1_hm_65'},{'rOA_1_hm_70'}]; 
attrNames(48:52) = [{'rOA_2_r_50'},{'rOA_2_r_55'},{'rOA_2_r_60'},{'rOA_2_r_65'},{'rOA_2_r_70'}]; 
attrNames(53:57) = [{'rOA_2_hm_50'},{'rOA_2_hm_55'},{'rOA_2_hm_60'},{'rOA_2_hm_65'},{'rOA_2_hm_70'}]; 

for j = 40 : 5 : 200
    attrNames{end+1} = sprintf('sOIV_n_%d',j);
end
for j = 40 : 5 : 200
    attrNames{end+1} = sprintf('sOIV_m_%d',j);
end

attrNames(124:126) = [{'mel_v_16'},{'mel_v_8'},{'mel_v_4'}];
attrNames(127:129) = [{'mel_max_16'},{'mel_max_8'},{'mel_max_4'}];
attrNames(130:132) = [{'mel_min_16'},{'mel_min_8'},{'mel_min_4'}];
attrNames(133:135) = [{'mel_l_16'},{'mel_l_8'},{'mel_l_4'}];
attrNames{136} = 'rOSN';
attrNames{137} = 'aFVKP_r';
attrNames(138:140) = [{'aFVKP_i_1st'},{'aFVKP_i_2nd'},{'aFVKP_i_3rd'}];
attrNames(141:144) = [{'aFIKP_4'},{'aFIKP_5'},{'aFIKP_6'},{'aFIKP_7'}];

allKeys = keys(freqToM);
for i = 1 : length(allKeys)
    k = allKeys{i};
    attrNames{freqToM(k)} = k;
end

attrNames{end+1} = 'label';

% time capture
fprintf('Done. Took %f seconds.\n', toc(begin));
end

function nmat = drop( nmat, channels)
    for i = 1 : length(channels)
        nmat = dropmidich(nmat, channels(i));
    end
end

function m = joinMaps(m, f)
    % join map f into m
    allKeys = keys(f);
    n = length(allKeys);
    
    for i = 1 : n
        k = allKeys{i};
        if (isKey(m, k))
            m(k) = m(k) + f(k);
        else
            m(k) = f(k);
        end
    end
    
end
