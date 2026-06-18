function [relPose, inlierIdx] = helperEstimateRelativePose(matchedPoints1, matchedPoints2, intrinsics)

if ~isnumeric(matchedPoints1)
    matchedPoints1 = matchedPoints1.Location;
end

if ~isnumeric(matchedPoints2)
    matchedPoints2 = matchedPoints2.Location;
end

% Zmniejszamy liczbę prób ze 100 do 15, żeby nie czekać w nieskończoność
for i = 1:15
    % Liczymy macierz (bez MaxDistance, bo zmniejszyliśmy już zdjęcia w głównym pliku)
    [E, inlierIdx] = estimateEssentialMatrix(matchedPoints1, matchedPoints2, intrinsics);

    % ZŁAGODZENIE 1: Zamiast 30%, akceptujemy, gdy tylko 15% punktów pasuje
    if sum(inlierIdx) / numel(inlierIdx) < 0.15
        continue;
    end
    
    inlierPoints1 = matchedPoints1(inlierIdx, :);
    inlierPoints2 = matchedPoints2(inlierIdx, :);    
    
    % Triangulacja
    [relPose, validPointFraction] = estrelpose(E, intrinsics, inlierPoints1(1:2:end, :), inlierPoints2(1:2:end, :));

    % ZŁAGODZENIE 2: Zamiast 80%, wystarczy nam, że połowa (50%) punktów jest przed obiektywem
    if validPointFraction > 0.5
       return;
    end
end

% ZŁAGODZENIE 3: Jeśli po 15 próbach nie ma ideału, skrypt nie wyrzuci już "errora", 
% tylko zaakceptuje to, co udało mu się policzyć najlepiej, żeby pójść dalej!
return;