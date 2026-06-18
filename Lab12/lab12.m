clc; clear; close all;

Left = imread('l.jpeg');
Right = imread('p.jpeg');
if any(size(Left) ~= size(Right)), Right = imresize(Right, [size(Left, 1), size(Left, 2)]); end

imgRight_sh = imtranslate(Right, [15, 0]);
anag_std = zeros(size(Left), 'uint8');
anag_std(:,:,1) = Left(:,:,1);
anag_std(:,:,2) = imgRight_sh(:,:,2);
anag_std(:,:,3) = imgRight_sh(:,:,3);

h = fspecial('average', [9 9]);

imgLefty_filt = Left;
imgLefty_filt(:,:,1) = imfilter(Left(:,:,1), h, 'replicate');

anag_enh = zeros(size(Left), 'uint8');
anag_enh(:,:,1) = imgLefty_filt(:,:,1);
anag_enh(:,:,2) = imgRight_sh(:,:,2);
anag_enh(:,:,3) = imgRight_sh(:,:,3);

imwrite(anag_std, 'anaglif_standard.jpg', 'Quality', 100);
imwrite(anag_enh, 'anaglif_filtracja.jpg', 'Quality', 100);