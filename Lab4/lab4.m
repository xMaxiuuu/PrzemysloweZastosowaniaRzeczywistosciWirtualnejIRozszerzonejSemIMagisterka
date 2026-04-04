clear all; 
close all; clc;

% Kalibracja Kamery
files = {'portfel1.jpeg', 'portfel2.jpeg', 'zegarek1.jpeg'};
[imagePoints, boardSize] = detectCheckerboardPoints(files);
squareSize = 25; 
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
tempImg = imread(files{1});
cameraParams = estimateCameraParameters(imagePoints, worldPoints, 'ImageSize', [size(tempImg,1), size(tempImg,2)]);

try
    cam = webcam(); 
catch
    error('Błąd: Nie można połączyć się z kamerą.');
end

targetSize = cameraParams.Intrinsics.ImageSize; 
testFrame = snapshot(cam);
camSize = [size(testFrame, 1), size(testFrame, 2)]; 

liveFig = figure('Name', 'Lab 4', 'NumberTitle', 'off', 'Position', [400, 50, 600, 950]);

% HSV dla wykrywanego koloru
hMin1 = 0.00; hMax1 = 0.05; hMin2 = 0.95; hMax2 = 1.00;
sMin = 0.65; sMax = 1.00; vMin = 0.40; vMax = 1.00;

win1 = subplot(3, 1, 1); hOrig = imshow(zeros(camSize)); title('Oryginał (RAW)');
win2 = subplot(3, 1, 2); hUndist = imshow(zeros(camSize)); title('Po Korekcji');
win3 = subplot(3, 1, 3); hTrack = imshow(zeros(camSize)); title('Maska');

disp('Program uruchomiony.');

% Pętla Przetwarzania
while ishandle(liveFig)
    % Pobranie klatki i Korekcja
    trueFrame = snapshot(cam);
    calcFrame = imresize(trueFrame, targetSize); 
    undistortedCalc = undistortImage(calcFrame, cameraParams);
    undistortedDisplay = imresize(undistortedCalc, camSize); 
    
    % Tworzenie maski
    hsvImg = rgb2hsv(undistortedDisplay);
    mask = ((hsvImg(:,:,1) >= hMin1 & hsvImg(:,:,1) <= hMax1) | ...
            (hsvImg(:,:,1) >= hMin2 & hsvImg(:,:,1) <= hMax2)) & ...
            (hsvImg(:,:,2) >= sMin & hsvImg(:,:,2) <= sMax) & ...
            (hsvImg(:,:,3) >= vMin & hsvImg(:,:,3) <= vMax);
    mask = imclose(mask, strel('disk', 15));
    mask = imopen(mask, strel('disk', 5));
    
    maskedRGB = undistortedDisplay;
    bgPixels = repmat(~mask, [1, 1, 3]);
    maskedRGB(bgPixels) = uint8(double(maskedRGB(bgPixels)) * 0.15);
    
    % Położenie
    stats = regionprops(mask, 'Centroid', 'Area', 'BoundingBox');
    
    % Aktualizacja obrazów
    set(hOrig, 'CData', trueFrame);
    set(hUndist, 'CData', undistortedDisplay);
    set(hTrack, 'CData', maskedRGB);
    
    % Ramka
    axes_list = [win1, win2, win3];
    for i = 1:3
        hold(axes_list(i), 'on');
        delete(findobj(axes_list(i), 'Type', 'rectangle')); 
        delete(findobj(axes_list(i), 'Type', 'text'));
    end

    if ~isempty(stats)
        [~, idx] = max([stats.Area]);
        bBox = stats(idx).BoundingBox;
        centroid = stats(idx).Centroid;
        
        for i = 1:3
            rectangle(axes_list(i), 'Position', bBox, 'EdgeColor', [0 1 0], 'LineWidth', 2);
            text(axes_list(i), bBox(1), bBox(2) - 15, ...
                sprintf('X: %.0f, Y: %.0f', centroid(1), centroid(2)), ...
                'Color', 'green', 'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', 'black');
        end
    end
    
    for i = 1:3, hold(axes_list(i), 'off'); end
    
    drawnow limitrate; 
end

clear cam;