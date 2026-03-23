clc; clear; close all;

input = imread("rozszerzony.jpeg"); 
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

chart = colorChecker(input, "RegistrationPoints", cornerPoints);
colorTab = measureColor(chart);

% Kolory
srccolor = double([colorTab.Measured_R, colorTab.Measured_G, colorTab.Measured_B]);
if max(srccolor(:)) > 1
    srccolor = srccolor / 255;
end
target = double([colorTab.Reference_L, colorTab.Reference_a, colorTab.Reference_b]);
target_colors = lab2rgb(target);

img_lin = im2double(input);
[h, w, c] = size(img_lin);
img_lin_flat = reshape(img_lin, h * w, c);

% Transformation 3x3
model_linear = ccmtrain(srccolor, target_colors, 'model', 'linear3x3');
img_linear_flat = ccmapply(img_lin_flat, 'linear3x3', model_linear);
img_linear = reshape(img_linear_flat, h, w, c); % Przywracanie wymiarów zdjęcia

% Polynomial regression 6x3
model_poly = ccmtrain(srccolor, target_colors, 'model', 'poly6x3');
img_poly_flat = ccmapply(img_lin_flat, 'poly6x3', model_poly);
img_poly = reshape(img_poly_flat, h, w, c);

% Root-polynomial regression 6x3
model_root = ccmtrain(srccolor, target_colors, 'model', 'root6x3');
img_root_flat = ccmapply(img_lin_flat, 'root6x3', model_root);
img_root = reshape(img_root_flat, h, w, c);

% Zabezpieczenie
img_linear = min(max(img_linear, 0), 1);
img_poly   = min(max(img_poly, 0), 1);
img_root   = min(max(img_root, 0), 1);

% Wyniki
figure;
subplot(2, 2, 1); 
imshow(input); 
title('Obraz oryginalny');

subplot(2, 2, 2); 
imshow(img_linear); 
title('Linear transformation 3x3');

subplot(2, 2, 3); 
imshow(img_poly); 
title('Polynomial regression 6x3');

subplot(2, 2, 4); 
imshow(img_root); 
title('Root-polynomial regression 6x3');