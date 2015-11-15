function bool = test(note, scale)
%test tests wether a note is part of a scale 
if (~isempty(find(scale == mod(note, 12))))
    bool = 1;
else
    bool = 0;
end
end


