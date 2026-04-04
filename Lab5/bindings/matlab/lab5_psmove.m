clear all; close all; clc;

% Inicjalizacja kamery
try
    cam = webcam(); 
catch
    error('Nie można zainicjować kamery. Sprawdź połączenie.');
end

hFig = figure('Name', 'Lab 5', 'NumberTitle', 'off');
hAx = axes('Parent', hFig);


% Pętla przetwarzania
while ishandle(hFig)
    % Pobranie klatki
    img = snapshot(cam);
    img = flip(img, 2); 
    
    % Sprawdzenie czy okno nadal istnieje przed rysowaniem
    if ~ishandle(hFig), break; end
    
    % Czyszczenie poprzedniego punktu
    cla(hAx);
    
    % Wyświetlenie tła
    imshow(img, 'Parent', hAx);
    hold(hAx, 'on');
    
    % Estymacja
    grayImg = rgb2gray(img);
    bw = imbinarize(grayImg, 0.9); % Progowanie jasności
    bw = imopen(bw, strel('disk', 2)); % Usuwanie szumów
    
    stats = regionprops(bw, 'Centroid', 'Area');
    
    if ~isempty(stats)
        [~, idx] = max([stats.Area]);
        loc = stats(idx).Centroid;
        
        % Wypisywanie pozycji
        fprintf('Pozycja kontrolera: X = %4.0f, Y = %4.0f\n', loc(1), loc(2));
        
        % Rysowanie estymacji
        plot(hAx, loc(1), loc(2), 'ro', 'MarkerSize', 15, 'LineWidth', 3);
        text(hAx, loc(1)+20, loc(2), sprintf('X: %.0f, Y: %.0f', loc(1), loc(2)), ...
            'Color', 'red', 'FontSize', 12, 'FontWeight', 'bold');
    end
    
    if ishandle(hFig)
        hold(hAx, 'off');
    end
    drawnow;
end

% Sprzątanie po zamknięciu okna
if exist('cam', 'var')
    clear cam;
end
disp('Program zakończony poprawnie.');