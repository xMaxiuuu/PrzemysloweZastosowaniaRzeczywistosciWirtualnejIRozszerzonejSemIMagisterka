clear; clc; close all;

addpath('imlut'); 

% Input
obraz_input = 'yoda.jpg';
folder_luts = 'LUTs';
wybrany_lut = 'Hyla 68.CUBE'; 

sciezka_lut = fullfile(folder_luts, wybrany_lut);

% Wczytanie obrazu
if exist(obraz_input, 'file')
    img = imread(obraz_input);
else
    error('Nie znaleziono pliku %s', obraz_input);
end

% Wczytywanie pliku .CUBE
try
    % Filtrowanie danych liczbowych
    fid = fopen(sciezka_lut, 'r');
    tline = fgetl(fid);
    data = [];
    while ischar(tline)
        % Odfiltruje linie typu "TITLE", "LUT_3D_SIZE"
        if ~isempty(tline) && (isstrprop(tline(1), 'digit') || tline(1) == '-' || tline(1) == '.')
            data = [data; str2num(tline)];
        end
        tline = fgetl(fid);
    end
    fclose(fid);
    
    if isempty(data)
        error('Plik LUT jest pusty lub ma nieznany format.');
    end
    lut_data = data;
catch
    error('Błąd podczas odczytu pliku LUT. Sprawdź format pliku .CUBE.');
end

% Korekcja kolorystycznej
try
    img_corrected = imlut(img, lut_data, '3D', 'standard', 'RGB');
catch ME
    error('Błąd podczas działania funkcji imlut: %s', ME.message);
end

% Wyświetlenie wyników
figure('Name', 'Wynik Korekcji');
subplot(1,2,1);
imshow(img);
title('Oryginał');

subplot(1,2,2);
imshow(img_corrected);
title(['LUT: ', wybrany_lut]);

% Zapisanie wyniku
imwrite(img_corrected, 'yoda_corrected.jpg');
disp('Sukces! Obraz został przetworzony i zapisany.');