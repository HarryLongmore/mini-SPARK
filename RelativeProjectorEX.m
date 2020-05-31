%RelativeProjectorEX calculates the transformation and roation between a
%projector and camera 

%From intrinsic parameters a calibration checkerboard is pre distored and
%projected onto a tangential wall. The image of the projection should be
%saved as "proExtrin.jpg"

%Undistored projected cherboard image should be saved as "checkerboard.jpg"

%The square size of the projected should be measured 

%OutPut is a Homogenous Matrix 

function [Pro2Cam] = RelativeProjectorEX(proIntrinsics,camIntrinsics,measuredSquare)

    %proIntrinsics = structure containing Projector Intrinsic Parameters
    %made from function "cameraIntrinsics"

    %camIntrinsics = structure containing camera Intrinsic Parameters
    %made from function "cameraIntrinsics"
    
    %measuredSquare = measured square size of projected checkerboard square
    %in mm
    
%Intrinsic parameters need to be sorted into two different classes due
%to function compatabilites 

    IntrinsicMatrix = camIntrinsics.IntrinsicMatrix;
    intrinsicz = cameraParameters('IntrinsicMatrix',IntrinsicMatrix,'imageSize',camIntrinsics.ImageSize,"RadialDistortion",camIntrinsics.RadialDistortion);
 
%Read Image or projected calibration board
    camIm = imread("proExtrin.jpg");
    
%Undistort Image
    [im,newOrigin] = undistortImage(camIm,camIntrinsics,'OutputView','full');
%Detect checkerboard     
    [imagePoints,boardSize] = detectCheckerboardPoints(im);

    imagePoints = [imagePoints(:,1) + newOrigin(1), ...
             imagePoints(:,2) + newOrigin(2)];
         
%Ideal points of projected checkerboard croners     
    worldPoints = generateCheckerboardPoints(boardSize, measuredSquare);     
    
%Translation and Roation from camera to world points       
    [CamRotationMatrix, CamTranslationVector] = extrinsics(...
            imagePoints,worldPoints,camIntrinsics);
    
 
    
%Find projector Extrinsic

%World points of projected checkerboard
projectedPoints = pointsToWorld(intrinsicz,CamRotationMatrix,CamTranslationVector,imagePoints);

%Undistored projected cherboard image 
proIm = imread("checkerboard.jpg");

%Image points of projected checkerboard
[imageProPoints,boardSize] = detectCheckerboardPoints(proIm);


%Translation and Roation from projector to world points    
[ProRotationMatrix, ProTranslationVector] = extrinsics(...
        imageProPoints,projectedPoints,proIntrinsics)
    
    
    
    
%Form Rotation and Translation into Homogenous transfromation
    Points2CamRotationMatrix = inv(CamRotationMatrix);
    points2CamTranslationVector = -Points2CamRotationMatrix*CamTranslationVector';

%Initialize Matrices 
    HomoPoint2Cam = zeros(4);
    HomoPro2Point = zeros(4);

    HomoPoint2Cam(4,4) = 1;
    HomoPro2Point(4,4) = 1;

    HomoPoint2Cam(1:3,1:3) = Points2CamRotationMatrix;
    HomoPoint2Cam(1:3,4) = points2CamTranslationVector;

    HomoPro2Point(1:3,1:3) = ProRotationMatrix;
    HomoPro2Point(1:3,4) = ProTranslationVector;


    Pro2Cam = HomoPro2Point*HomoPoint2Cam;
end

