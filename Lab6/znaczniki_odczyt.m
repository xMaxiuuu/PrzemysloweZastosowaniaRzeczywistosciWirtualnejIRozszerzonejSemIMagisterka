clear all; close all; clc;

try
    cam = webcam(); 
catch
    error('Kamera zablokowana. Wpisz w konsoli "clear cam" i uruchom skrypt ponownie.');
end

hFig = figure('Name', 'Lab 6 znaczniki', 'NumberTitle', 'off');
hAx = axes('Parent', hFig);

% Zamykanie kamery (przycisk X)
set(hFig, 'CloseRequestFcn', 'if exist(''cam'', ''var''); clear cam; disp(''Kamera zwolniona poprawnie.''); end; delete(gcf);');

% Lista słowników (4x4, 5x5, 6x6, 7x7)
markerFamilies = ["DICT_4X4_50", "DICT_5X5_100", "DICT_6X6_250", "DICT_7X7_100"];

% Kolory poszczególnych słowników: 
boxColors = ['r', 'b', 'g', 'm']; % czerwony (4x4), niebieski (5x5), zielony (6x6), magenta (7x7)

disp('Program uruchomiony');

% Główna pętla
while ishandle(hFig)
    % Pobranie klatki
    img = snapshot(cam);
    cla(hAx);
    imshow(img, 'Parent', hAx);
    hold(hAx, 'on');
    
    % Przeszukiwanie obrazu
    for famIdx = 1:length(markerFamilies)
        currentFamily = markerFamilies(famIdx);
        currentColor = boxColors(famIdx);
        
        % Szukanie znaczników
        [ids, locs] = readArucoMarker(img, currentFamily);
        
        if ~isempty(ids)
            for i = 1:length(ids)
                % Pobieranie rogów
                markerCorners = locs(:, :, i);
               
                x_pts = [markerCorners(:, 1); markerCorners(1, 1)];
                y_pts = [markerCorners(:, 2); markerCorners(1, 2)];
                
                % Rysowanie ramki
                plot(hAx, x_pts, y_pts, '-', 'Color', currentColor, 'LineWidth', 4);
                
                % Tworzenie etykiety
                centerLoc = mean(markerCorners);
                nameParts = split(currentFamily, '_'); % Wyciąga rozmiar z nazwy słownika
                shortName = nameParts(2);
                
                textToDisplay = sprintf('%s ID: %d', shortName, ids(i));
                text(hAx, centerLoc(1), centerLoc(2), textToDisplay, ...
                    'Color', currentColor, 'FontSize', 16, 'FontWeight', 'bold');
            end
        end
    end
    
    hold(hAx, 'off');
    drawnow; % Aktualizacja obrazu i obsługa
end