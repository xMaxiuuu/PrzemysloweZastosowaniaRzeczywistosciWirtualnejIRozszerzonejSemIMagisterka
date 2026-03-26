clear all; close all; clc;

files = {'portfel1.jpeg', 'portfel2.jpeg', 'zegarek1.jpeg'};

% Kalibracja
checkerFiles = {'portfel1.jpeg', 'portfel2.jpeg', 'zegarek1.jpeg'};
[imagePoints, boardSize] = detectCheckerboardPoints(checkerFiles);
squareSize = 25; % Rozmiar boku kwadratu w mm
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Pobranie parametrów kamery
tempImg = imread(files{1});
cameraParams = estimateCameraParameters(imagePoints, worldPoints, 'ImageSize', [size(tempImg,1), size(tempImg,2)]);

for i = 1:length(files)
    img = imread(files{i});
    undistorted = undistortImage(img, cameraParams);
    figure('Name', ['Wynik dla: ', files{i}], 'NumberTitle', 'off');
    
    % Oryginał
    subplot(1, 2, 1);
    imshow(img);
    title('Obraz oryginalny');
    
    % Po korekcji
    subplot(1, 2, 2);
    imshow(undistorted);
    title('Obraz po korekcji');
end

% Wyniki
fprintf('====================================================================\n');
fprintf('Współczynniki Radial Distortion: [%.4f, %.4f]\n', cameraParams.RadialDistortion(1), cameraParams.RadialDistortion(2));
fprintf('Współczynniki Tangential Distortion: [%.4f, %.4f]\n', cameraParams.TangentialDistortion(1), cameraParams.TangentialDistortion(2));
fprintf('Ogniskowa (Focal Length): [%.2f, %.2f]\n', cameraParams.Intrinsics.FocalLength(1), cameraParams.Intrinsics.FocalLength(2));
fprintf('====================================================================\n');

% Kamera
fprintf('Uruchamianie kamery...\n');
try
    cam = webcam(); 
catch
    error('Błąd kamery');
end

% Rozmiar obrazów kalibracyjnych z parametrów
targetSize = cameraParams.Intrinsics.ImageSize; 

liveFig = figure('Name', 'Kamera na żywo', 'NumberTitle', 'off');

% Pobranie pierwszej klatki w celu inicjalizacji
trueFrame = snapshot(cam); % Nieskalowany obraz
camSize = [size(trueFrame, 1), size(trueFrame, 2)];

% Skalowanie
calcFrame = imresize(trueFrame, targetSize); % Obliczenia dla 4:3
undistortedFrame = undistortImage(calcFrame, cameraParams); % Korekcja
displayUndistorted = imresize(undistortedFrame, camSize); % Rozciąganie do 16:9!

% Inicjalizacja szybkiego wyświetlania
subplot(1, 2, 1);
hOrig = imshow(trueFrame); 
title('Kamera - Oryginał');

subplot(1, 2, 2);
hUndist = imshow(displayUndistorted);
title('Kamera - Po korekcji');

disp('Kamera działa poprawnie');

% Pętla wideo w czasie rzeczywistym
while ishandle(liveFig)
    % Pobieramy klatkę - 16:9
    trueFrame = snapshot(cam);
    
    % Ściskanie px -> Korygowanie -> Rozciąganie do 16:9
    calcFrame = imresize(trueFrame, targetSize); 
    undistortedFrame = undistortImage(calcFrame, cameraParams);
    displayUndistorted = imresize(undistortedFrame, camSize); 
    
    % Aktualizacja pikseli
    set(hOrig, 'CData', trueFrame); 
    set(hUndist, 'CData', displayUndistorted); 
    drawnow; 
end

clear cam;
disp('Kamera została odłączona');