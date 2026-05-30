clc; clear; close all;

addpath(genpath('tools')); 
onnxFile = fullfile('tools', 'human-pose-estimation.onnx');

net = importNetworkFromONNX(onnxFile);
inputSize = net.Layers(1).InputSize;
net = initialize(net, dlarray(zeros(inputSize), "SSC"));
params = getBodyPoseParameters; 

% Parametry detekcji
params.MaxNumPeople = 1;       
params.ThinningThreshold = 0.1; 
params.MinPAFScore = 0.1;      

% Wygladzanie
smoothWindow = 5; 
poseBuffer = [];

% Zdjecie
zdjecia = {'photo.jpeg'}; 
for i = 1:length(zdjecia)
    if exist(zdjecia{i}, 'file')
        im = imread(zdjecia{i});
        nInput = im2single(im) - 0.5;
        [heatmaps, pafs] = predict(net, dlarray(nInput(:,:,[3 2 1]), "SSC"));
        poses = getBodyPoses(extractdata(heatmaps), extractdata(pafs), params);
        if ~isempty(poses)
            if size(poses, 3) == 2, poses(:,:,3) = 1; end
            poses = poses(1, :, :);
        end
        f = figure('Visible', 'off', 'Color', 'w');
        renderBodyPoses(im, poses, size(heatmaps,1), size(heatmaps,2), params);
        axis off;
        exportgraphics(f, ['Wynik_Foto' num2str(i) '.png'], 'Resolution', 300);
        close(f);
    end
end

% Wideo
videoFile = 'film.mov';
if exist(videoFile, 'file')
    v = VideoReader(videoFile);
    
    outputVideo = VideoWriter('wynik_wideo.mp4', 'MPEG-4');
    outputVideo.FrameRate = v.FrameRate;
    open(outputVideo);
    
    f_vid = figure('Visible', 'off', 'Units', 'pixels', 'Position', [0 0 v.Width v.Height]); 
    
    while hasFrame(v)
        frame = readFrame(v);
        nInput = im2single(frame) - 0.5;
        [h, p] = predict(net, dlarray(nInput(:,:,[3 2 1]), "SSC"));
        ps = getBodyPoses(extractdata(h), extractdata(p), params);
        
        if ~isempty(ps)
            % Normalizacja wymiarów
            if size(ps, 3) == 2, ps(:,:,3) = 1; end
            currentPose = ps(1, :, :);
            
            % Wygladzanie
            poseBuffer = cat(4, poseBuffer, currentPose);
            if size(poseBuffer, 4) > smoothWindow
                poseBuffer(:,:,:,1) = [];
            end
            smoothPose = mean(poseBuffer, 4);
        else
            smoothPose = [];
            poseBuffer = [];
        end
        
        clf(f_vid);
        ax_v = axes('Parent', f_vid, 'Units', 'normalized', 'Position', [0 0 1 1]);
        renderBodyPoses(frame, smoothPose, size(h,1), size(h,2), params);
        axis(ax_v, 'off');
        drawnow;

        captured = getframe(f_vid);
        resizedFrame = imresize(captured.cdata, [v.Height, v.Width]);
        writeVideo(outputVideo, resizedFrame);
    end
    
    close(outputVideo);
    close(f_vid);
    fprintf('GOTOWE!');
end