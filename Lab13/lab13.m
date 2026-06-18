input = 'video.mov'; 
videosrc = VideoReader(input);

output = 'video_stabilizacja.avi';
out = VideoWriter(output);
out.FrameRate = videosrc.FrameRate;
open(out);

img = readFrame(videosrc);
img_gray = im2gray(img);
cTform = affinetform2d(); 

Thresh = 0.1;


while hasFrame(videosrc)
    imgf = readFrame(videosrc);
    imgf_gray = im2gray(imgf);

    pointA = detectFASTFeatures(img_gray, 'MinContrast', Thresh);
    pointB = detectFASTFeatures(imgf_gray, 'MinContrast', Thresh);
    [featuresA, validPointsA] = extractFeatures(img_gray, pointA);
    [featuresB, validPointsB] = extractFeatures(imgf_gray, pointB);

    index_Pairs = matchFeatures(featuresA, featuresB);
    matched_PointA = validPointsA(index_Pairs(:, 1), :);
    matched_PointB = validPointsB(index_Pairs(:, 2), :);

    if size(matched_PointA, 1) >= 3
        try
            [tform, ~] = estgeotform2d(matched_PointB, matched_PointA, 'similarity');
            T = tform.A;
            scale = sqrt(T(1,1)^2 + T(2,1)^2);
            T(1:2, 1:2) = T(1:2, 1:2) / scale; 
            tform = affinetform2d(T);
            cTform.A = cTform.A * tform.A;
        catch
        end
    end
    outputView = imref2d(size(imgf));
    imgB_stabilized = imwarp(imgf, cTform, 'OutputView', outputView);
    writeVideo(out, imgB_stabilized);

    img_gray = imgf_gray;
end

close(out);