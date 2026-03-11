%% Korekcja kolorów - Skrypt przygotowany pod Twoją strukturę plików
clear; clc; close all;

% Dodajemy toolbox do ścieżki (żeby MATLAB widział ccmtrain, ccmapply i utils)
addpath(genpath('color-correction-toolbox'));

% Definicja nazw Twoich plików
file_classic = 'podstawowy.jpeg';
file_sg = 'rozszerzony.jpeg';

%% --- ZADANIE 1: Korekcja liniowa macierzą 3x4 (Wzornik Classic) ---
fprintf('ZADANIE 1: Przetwarzanie wzornika Classic...\n');
img1 = im2double(imread(file_classic));

% Ręczne pobranie kolorów (skoro nie masz Image Processing Toolbox)
fprintf('Kliknij w środki 24 pól na zdjęciu (rzędami od góry, od lewej do prawej).\n');
imshow(img1); title('Zaznacz 24 pola wzornika Classic');
[x1, y1] = ginput(24); 

measuredRGB1 = zeros(24, 3);
for j = 1:24
    % Średnia z kwadratu 11x11 pikseli wokół kliknięcia
    patch = img1(round(y1(j))-5:round(y1(j))+5, round(x1(j))-5:round(x1(j))+5, :);
    measuredRGB1(j, :) = mean(reshape(patch, [], 3));
end

% Referencyjne wartości RGB dla X-Rite Classic (standardowe wartości sRGB)
refRGB1 = [0.45,0.32,0.24; 0.76,0.58,0.50; 0.36,0.47,0.57; 0.35,0.42,0.25; ...
           0.51,0.50,0.73; 0.38,0.74,0.66; 0.85,0.48,0.18; 0.28,0.36,0.69; ...
           0.76,0.32,0.37; 0.36,0.22,0.41; 0.62,0.74,0.25; 0.90,0.64,0.11; ...
           0.18,0.22,0.53; 0.28,0.58,0.27; 0.69,0.22,0.23; 0.93,0.78,0.04; ...
           0.73,0.31,0.59; 0.00,0.53,0.64; 0.95,0.95,0.95; 0.78,0.78,0.78; ...
           0.63,0.63,0.63; 0.47,0.47,0.47; 0.33,0.33,0.33; 0.13,0.13,0.13];

% Macierz 3x4 (Liniowa z offsetem / wyrazem wolnym)
% Model: [R G B] = [Rin Gin Bin 1] * M'
A = [measuredRGB1, ones(24, 1)];
M_3x4 = (A \ refRGB1)'; 

% Zastosowanie macierzy na całym obrazie
[h1, w1, ~] = size(img1);
img_vec1 = reshape(img1, [], 3);
corrected_3x4 = reshape([img_vec1, ones(h1*w1, 1)] * M_3x4', h1, w1, 3);

%% --- ZADANIE 2: Trzy modele dla wzornika SG (Zielone światło) ---
fprintf('\nZADANIE 2: Przetwarzanie wzornika SG (zielone światło)...\n');
img2 = im2double(imread(file_sg));

fprintf('Kliknij w te same 24 pola na wzorniku SG (zielone zdjęcie).\n');
imshow(img2); title('Zaznacz 24 pola na wzorniku SG');
[x2, y2] = ginput(24);

measuredRGB2 = zeros(24, 3);
for j = 1:24
    patch = img2(round(y2(j))-5:round(y2(j))+5, round(x2(j))-5:round(x2(j))+5, :);
    measuredRGB2(j, :) = mean(reshape(patch, [], 3));
end

% Model A: Linear (Liniowy)
ccm_lin = ccmtrain(measuredRGB2, refRGB1, 'model', 'linear');
img_lin = ccmapply(img2, ccm_lin);

% Model B: Polynomial (Wielomianowy 2. stopnia)
ccm_poly = ccmtrain(measuredRGB2, refRGB1, 'model', 'poly2');
img_poly = ccmapply(img2, ccm_poly);

% Model C: Root-polynomial (Pierwiastkowy)
ccm_root = ccmtrain(measuredRGB2, refRGB1, 'model', 'root-poly2');
img_root = ccmapply(img2, ccm_root);

%% --- WYŚWIETLANIE WYNIKÓW ---

% Okno 1: Zadanie 1
figure('Name', 'Zadanie 1: Korekcja Liniowa 3x4');
subplot(1,2,1); imshow(img1); title('Oryginał');
subplot(1,2,2); imshow(corrected_3x4); title('Korekcja 3x4');

% Okno 2: Zadanie 2 (Porównanie modeli)
figure('Name', 'Zadanie 2: Modele Rozszerzone (Toolbox)');
subplot(2,2,1); imshow(img2); title('Oryginał (Zielone)');
subplot(2,2,2); imshow(img_lin); title('Model: Linear');
subplot(2,2,3); imshow(img_poly); title('Model: Poly2');
subplot(2,2,4); imshow(img_root); title('Model: Root-Poly2');

fprintf('\nProces zakończony. Możesz zapisać obrazy do raportu PDF.\n');