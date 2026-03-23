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
    title('Obraz oryginalny (zniekształcony)');
    
    % Po korekcji
    subplot(1, 2, 2);
    imshow(undistorted);
    title('Obraz po korekcji (undistortImage)');
end

% Wyniki
fprintf('Współczynniki Radial Distortion: [%.4f, %.4f]\n', cameraParams.RadialDistortion(1), cameraParams.RadialDistortion(2));
fprintf('Współczynniki Tangential Distortion: [%.4f, %.4f]\n', cameraParams.TangentialDistortion(1), cameraParams.TangentialDistortion(2));
fprintf('Ogniskowa (Focal Length): [%.2f, %.2f]\n', cameraParams.Intrinsics.FocalLength(1), cameraParams.Intrinsics.FocalLength(2));