clear all; close all; clc;

% --- Znaczniki 4x4 ---
figure('Name', '4x4 (ID: 1)', 'NumberTitle', 'off');
imshow(generateArucoMarker("DICT_4X4_50", 1, 200));

figure('Name', '4x4 (ID: 2)', 'NumberTitle', 'off');
imshow(generateArucoMarker("DICT_4X4_50", 2, 200));

% --- Znaczniki 5x5 ---
figure('Name', '5x5 (ID: 3)', 'NumberTitle', 'off');
imshow(generateArucoMarker("DICT_5X5_100", 3, 200));

figure('Name', '5x5 (ID: 4)', 'NumberTitle', 'off');
imshow(generateArucoMarker("DICT_5X5_100", 4, 200));

% --- Znaczniki 6x6 ---
figure('Name', '6x6 (ID: 5)', 'NumberTitle', 'off');
imshow(generateArucoMarker("DICT_6X6_250", 5, 200));

figure('Name', '6x6 (ID: 6)', 'NumberTitle', 'off');
imshow(generateArucoMarker("DICT_6X6_250", 6, 200));

% --- Znaczniki 7x7 ---
figure('Name', '7x7 (ID: 7)', 'NumberTitle', 'off');
imshow(generateArucoMarker("DICT_7X7_100", 7, 200));

figure('Name', '7x7 (ID: 8)', 'NumberTitle', 'off');
imshow(generateArucoMarker("DICT_7X7_100", 8, 200));