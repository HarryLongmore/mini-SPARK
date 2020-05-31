%CalProjector calibrates a projector from a set of calibration images and
%intrinsic camera parameters 

%image pairs should be named "cam1.jpg" - "camX.jpg"
%image for images of the camera calibration board

%image pairs should be named "pro1.jpg" - "proX.jpg"
%image for images of the projected calibration board

function [proParam,estimationErrors] = CalProjector(sampels,camBoard,squareSize,proBoard,focalLength,principalPoint,imageSize,RadialDistortion)

 
    %samples = Int. No. of image sample pairs 
    %camBoard = 1x2 vector, The No. of squares on the cameras calibration board
    %squareSize = measured size of printed calibration checkerboard square
    %in mm
    %proBoard = 1x2 vector, The No. of squares on the projectors
    %calibration pattern
    %focalLength = 2x1, from camera calibration
    %principalPoint = 2x1, from camera calibration
    %imageSize = 2x1, from camera calibration
    %RadialDistortion = 2x1, from camera calibration


    %Intrinsic parameters need to be sorted into two different classes due
    %to function compatabilites 
    IntrinsicMatrix = [focalLength(1),0,0;0,focalLength(2),0;principalPoint(1),principalPoint(2),1];
    
    intrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize,"RadialDistortion",RadialDistortion);

    intrinsicz = cameraParameters('IntrinsicMatrix',IntrinsicMatrix,'imageSize',imageSize,"RadialDistortion",RadialDistortion);


%read camera calibration board images 
    genfile = 'cam';
    endfile = '.jpg';
    filename = strcat(genfile,"1",endfile);   
    imsize = size(imread(filename));
    camera = zeros(imsize(1),imsize(2),smaples);
    camera = uint8(camera);
%pull calibration board photos 
    for i = 1:smaples 
        number = num2str(i);
        filename = strcat(genfile,number,endfile);   
        hold = imread(filename);
        camera(:,:,i) = rgb2gray(hold);
    end
    
    
%find camera pose
    
% Initialize camera properties     
    rotationMatrix = zeros(3,3,smaples);
    translationVector = zeros(1,3,smaples);
    
    %counts the bad images of the calibration board to be discarded
    badim = ones(1,sampels);

    for i = 1:sampels 
        %undistor images
        [im,newOrigin] = undistortImage(camera(:,:,i),intrinsics,'OutputView','full');
        %find calibration board points
        [imagePoints,boardSize] = detectCheckerboardPoints(im);
        imagePoints = [imagePoints(:,1) + newOrigin(1), ...
             imagePoints(:,2) + newOrigin(2)];
        %compare to expexted number of board points
        if boardSize == camBoard    
            %find extrinsic params
            worldPoints = generateCheckerboardPoints(boardSize, squareSize);     
            [rotationMatrix(:,:,i), translationVector(:,:,i)] = extrinsics(...
            imagePoints,worldPoints,intrinsics);
        else 
            %count failed images due to differing board points
            badim(i) = 0;
        end        
    end


%pull projected caibration board photos 

    genfile = 'pro';
    %nunber of passed images
    goodim = size(find(badim));
    %Initizalise projector properties 
    projector = zeros(imsize(1),imsize(2),goodim(2));
    projector = uint8(projector);
    goodcamR = zeros(3,3,smaples);
    goodcamT = zeros(1,3,smaples);

    %counting variables for sorting bad images
    M = 1;
    N = 1;
    while M <= goodim(2)+1
        %checks if assiosiated camera image is valid
        if badim(M) == 1
            number = num2str(M);
            filename = strcat(genfile,number,endfile);   
            hold = imread(filename);
            projector(:,:,N) = rgb2gray(hold);
            %passes the valid camera extrinsic params into a new array
            goodcamR(:,:,N) = rotationMatrix(:,:,M);
            goodcamT(:,:,N) = translationVector(:,:,M);
            M = M + 1;
            N = N + 1;
        else  
            M = M + 1;
        end
    end

% get projector world points 

    %Initialize counter for pass/fail projector calibration images
    N = 1; 
    badpro = ones(1,goodim(2));
    objectPoints = zeros((proBoard(1)-1)*(proBoard(2)-1),2);

    for i = 1:goodim(2)    
        %undistort image 
        [im,newOrigin] = undistortImage(projector(:,:,i),intrinsics,'OutputView','full');
        [imagePoints,boardSize] = detectCheckerboardPoints(im);
        
        %check expected board points to found
        if boardSize == proBoard 
            %find projected world points from camera params
            imagePoints = [imagePoints(:,1) + newOrigin(1), ...
            imagePoints(:,2) + newOrigin(2)];
            objectPoints(:,:,N) = pointsToWorld(intrinsicz,goodcamR(:,:,i),goodcamT(:,:,i),imagePoints);
            N = N + 1;
        else  
            badpro(i) = 0;    
        end    
    end 


    %Estimate projector intrinsics 
    objectPointsForCal = objectPoints;
    imPointsForCal = generateCheckerboardPoints(proBoard,squareSize);

    [proParam, ~, estimationErrors] = estimateCameraParameters(objectPointsForCal,imPointsForCal)


end

