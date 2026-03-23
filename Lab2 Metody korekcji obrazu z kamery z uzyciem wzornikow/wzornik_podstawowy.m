clc; clear; close all;

input = imread("podstawowyv3.jpeg");
imshow(input);

% Zaznaczanie punktów na wzorniku
blackPoint = drawpoint;
whitePoint = drawpoint;
darkSkinPoint = drawpoint;
bluishGreenPoint = drawpoint;

cornerPoints = [blackPoint.Position;
    whitePoint.Position;
    darkSkinPoint.Position;
    bluishGreenPoint.Position];

chart = colorChecker(input ,"RegistrationPoints",cornerPoints);
displayChart(chart)

% Pobranie kolorów i macierzy korekcji
[colorTable, ccm] = measureColor(chart);

% Konwersja obrazu do RGB (liniowa)
img_rgb = rgb2lin(input);

% Macierz korekcyjna
img_corrected = imapplymatrix(ccm(1:3,:)', img_rgb, ccm(4,:));

% Powrót do sRGB (Poprawne wyświetlanie zdjęcia)
img_corrected = lin2rgb(img_corrected);

% Wyniki
figure();
subplot(1, 2, 1);
imshow(input);
title('Oryginalne');

subplot(1, 2, 2);
imshow(img_corrected);
title('Po korekcji macierzą');


