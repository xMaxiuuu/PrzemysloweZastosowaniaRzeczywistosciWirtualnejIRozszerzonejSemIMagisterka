%% Lab 4: Śledzenie znacznika wideo
clear all; close all; clc;

%% 1. Wczytanie parametrów z Lab 3 (Korekcja geometrii)
% ODBLOKUJ poniższą linię, jeśli zapisałeś parametry z poprzedniego zadania:
% load('moje_parametry.mat'); 

%% 2. Inicjalizacja kamery
try
    cam = webcam(); % Uruchamia domyślną kamerę (zadziała na Twoim Macu)
catch
    error('Nie wykryto kamery. Sprawdź uprawnienia w systemie.');
end

figure('Name', 'Lab 4 - Śledzenie Znacznika', 'NumberTitle', 'off', 'Position', [100, 100, 1000, 500]);

%% 3. Pętla przetwarzania w czasie rzeczywistym
% Pętla działa dopóki okno z obrazem jest otwarte. Aby przerwać, po prostu zamknij okno.
while ishandle(1)
    % Pobranie klatki z kamery
    img = snapshot(cam);
    
    % --- KOREKCJA GEOMETRII (Wymóg z instrukcji) ---
    % ODBLOKUJ poniższą linię, jeśli wczytałeś cameraParams w kroku 1:
    % img = undistortImage(img, cameraParams);
    
    % --- ALGORYTM ŚLEDZENIA (Progowanie HSV) ---
    % Konwersja obrazu RGB na HSV (H-Barwa, S-Nasycenie, V-Jasność)
    hsv_img = rgb2hsv(img);
    H = hsv_img(:,:,1); 
    S = hsv_img(:,:,2); 
    V = hsv_img(:,:,3);
    
    % Zdefiniowanie progów dla koloru ZIELONEGO
    % (Wyświetl jaskrawozielone koło/kwadrat na telefonie, żeby przetestować)
    h_min = 0.25; h_max = 0.45; 
    s_min = 0.40; s_max = 1.00; 
    v_min = 0.30; v_max = 1.00; 
    
    % Progowanie - tworzenie maski binarnej
    mask = (H >= h_min) & (H <= h_max) & ...
           (S >= s_min) & (S <= s_max) & ...
           (V >= v_min) & (V <= v_max);
           
    % Oczyszczanie maski: zostawiamy tylko jeden, największy wykryty obiekt
    mask = bwareafilt(mask, 1); 
    
    % --- OKREŚLENIE LOKALIZACJI ---
    stats = regionprops(mask, 'Centroid', 'BoundingBox');
    
    tracked_img = img; % Kopia obrazu do narysowania znaczników
    
    if ~isempty(stats)
        % Pobranie współrzędnych środka ciężkości i prostokąta otaczającego
        centroid = stats(1).Centroid;
        bbox = stats(1).BoundingBox;
        
        % Rysowanie znacznika (prostokąt + czerwony krzyżyk na środku) - POPRAWIONA SKŁADNIA
        tracked_img = insertShape(tracked_img, 'Rectangle', bbox, 'Color', 'green', 'LineWidth', 3);
        tracked_img = insertMarker(tracked_img, centroid, 'x', 'Color', 'red', 'Size', 10);
    end
    
    % --- WYŚWIETLANIE ---
    subplot(1,2,1);
    imshow(tracked_img);
    title('Obraz po korekcji ze śledzeniem');
    
    subplot(1,2,2);
    imshow(mask);
    title('Maska (wykryty kolor)');
    
    drawnow; % Odświeżenie widoku
end

% Zakończenie pracy z kamerą po zamknięciu okna
clear cam;