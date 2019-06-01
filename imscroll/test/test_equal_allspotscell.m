[a,~] = size(old.AllSpotsCells);
logik = true(1,a);
for i = 1:a
    cp = old.AllSpotsCells{a,1} == new.AllSpotsCells{a,1};
    logik(a) = sum(~any(cp)) ==0;
end
sum(~any(logik))

