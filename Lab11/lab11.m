clear all; close all; clc;

imageDir = '/Users/maksymiliantonak/Documents/code/PrzemysloweZastosowaniaRzeczywistosciWirtualnejIRozszerzonejSemIMagisterka/Lab11/photo';
imds = imageDatastore(imageDir);

% WSPÓŁCZYNNIK SKALOWANIA: Zmniejszamy zdjęcia do 30% wielkości, aby uniknąć błędów
scaleFactor = 0.3; 

figure
montage(imds.Files, 'Size', [3, 2]);
title('Input Image Sequence');

% Wczytywanie, konwersja do szarości i SKALOWANIE obrazów
images = cell(1, numel(imds.Files));
for i = 1:numel(imds.Files)
    I = readimage(imds, i);
    I = im2gray(I);
    images{i} = imresize(I, scaleFactor); % Zmniejszanie obrazu
end

% Load Camera Parameters (Oszacowanie dla pomniejszonego obrazu)
imageSize = [size(images{1}, 1), size(images{1}, 2)];

% Oszacowanie ogniskowej
fx = max(imageSize) * 0.85;
fy = fx;
cx = imageSize(2) / 2;
cy = imageSize(1) / 2;

% Budowa macierzy parametrów wewnętrznych
intrinsicMatrix = [fx, 0, 0; 0, fy, 0; cx, cy, 1];
cameraParams = cameraParameters('IntrinsicMatrix', intrinsicMatrix, 'ImageSize', imageSize);
intrinsics = cameraParams.Intrinsics;

% Create a View Set Containing the First View
I = undistortImage(images{1}, intrinsics); 

border = 20; % Zmniejszony margines dla mniejszych zdjęć
roi = [border, border, size(I, 2)- 2*border, size(I, 1)- 2*border];
prevPoints   = detectSURFFeatures(I, NumOctaves=8, ROI=roi);
prevFeatures = extractFeatures(I, prevPoints, Upright=true);

vSet = imageviewset;
viewId = 1;
vSet = addView(vSet, viewId, rigidtform3d, Points=prevPoints);

% Add the Rest of the Views
for i = 2:numel(images)
    I = undistortImage(images{i}, intrinsics);
    
    currPoints   = detectSURFFeatures(I, NumOctaves=8, ROI=roi);
    currFeatures = extractFeatures(I, currPoints, Upright=true);    
    indexPairs   = matchFeatures(prevFeatures, currFeatures, MaxRatio=0.7, Unique=true);
    
    matchedPoints1 = prevPoints(indexPairs(:, 1));
    matchedPoints2 = currPoints(indexPairs(:, 2));
    
    % Tu funkcja powinna teraz przeliczyć wszystko błyskawicznie
    [relPose, inlierIdx] = helperEstimateRelativePose(matchedPoints1, matchedPoints2, intrinsics);
    relPose = relPose(1);
    prevPose = poses(vSet, i-1).AbsolutePose;
    currPose = rigidtform3d(prevPose.A * relPose.A);
    
    vSet = addView(vSet, i, currPose, Points=currPoints);
    vSet = addConnection(vSet, i-1, i, relPose, Matches=indexPairs(inlierIdx,:));
    
    tracks = findTracks(vSet);
    camPoses = poses(vSet);
    xyzPoints = triangulateMultiview(tracks, camPoses, intrinsics);
    
    [xyzPoints, camPoses, reprojectionErrors] = bundleAdjustment(xyzPoints, ...
        tracks, camPoses, intrinsics, FixedViewId=1, PointsUndistorted=true);

    vSet = updateView(vSet, camPoses);

    prevFeatures = currFeatures;
    prevPoints   = currPoints;  
end

% Display Camera Poses
camPoses = poses(vSet);
figure;
plotCamera(camPoses, Size=0.2);
hold on

goodIdx = (reprojectionErrors < 5);
xyzPoints = xyzPoints(goodIdx, :);

pcshow(xyzPoints, VerticalAxis='y', VerticalAxisDir='down', MarkerSize=45);
grid on
hold off

loc1 = camPoses.AbsolutePose(1).Translation;
xlim([loc1(1)-5, loc1(1)+4]);
ylim([loc1(2)-5, loc1(2)+4]);
zlim([loc1(3)-1, loc1(3)+20]);
camorbit(0, -30);
title('Refined Camera Poses');

% Compute Dense Reconstruction
I = undistortImage(images{1}, intrinsics); 
prevPoints = detectMinEigenFeatures(I, MinQuality=0.001);

tracker = vision.PointTracker(MaxBidirectionalError=1, NumPyramidLevels=6);
prevPoints = prevPoints.Location;
initialize(tracker, prevPoints, I);

vSet = updateConnection(vSet, 1, 2, Matches=zeros(0, 2));
vSet = updateView(vSet, 1, Points=prevPoints);

for i = 2:numel(images)
    I = undistortImage(images{i}, intrinsics); 
    [currPoints, validIdx] = step(tracker, I);
    
    if i < numel(images)
        vSet = updateConnection(vSet, i, i+1, Matches=zeros(0, 2));
    end
    vSet = updateView(vSet, i, Points=currPoints);
    
    matches = repmat((1:size(prevPoints, 1))', [1, 2]);
    matches = matches(validIdx, :);        
    vSet = updateConnection(vSet, i-1, i, Matches=matches);
end

tracks = findTracks(vSet);
camPoses = poses(vSet);
xyzPoints = triangulateMultiview(tracks, camPoses, intrinsics);

[xyzPoints, camPoses, reprojectionErrors] = bundleAdjustment(...
    xyzPoints, tracks, camPoses, intrinsics, FixedViewId=1, PointsUndistorted=true);

% Display Dense Reconstruction
figure;
plotCamera(camPoses, Size=0.2);
hold on

goodIdx = (reprojectionErrors < 5);
pcshow(xyzPoints(goodIdx, :), VerticalAxis='y', VerticalAxisDir='down', MarkerSize=45);
grid on
hold off

loc1 = camPoses.AbsolutePose(1).Translation;
xlim([loc1(1)-5, loc1(1)+4]);
ylim([loc1(2)-5, loc1(2)+4]);
zlim([loc1(3)-1, loc1(3)+20]);
camorbit(0, -30);
title('Dense Reconstruction');