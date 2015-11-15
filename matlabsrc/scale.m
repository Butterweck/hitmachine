function sc = scale( g, gt )
%scale returns major or minor scale for key gt
if (strcmp(g,'major'))
    sc = [gt gt+2 gt+4 gt+5 gt+7 gt+9 gt+11 gt+12];
    sc = mod(sc, 12);
elseif (strcmp(g,'minor'))
    sc = [gt gt+2 gt+3 gt+5 gt+7 gt+8 gt+10 gt+12];
    sc = mod(sc ,12);
end
end

