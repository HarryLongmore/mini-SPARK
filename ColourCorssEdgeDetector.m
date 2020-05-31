%This script creates edge images for detecting a colour cross marker

%Threshholds for the colour boundaries

%general threshold 
threshold = 200;
%green threshold 
gthreshold = 155;
%red threshold 
rthreshold = 190;
%blue threshold 
bthreshold = 170;

rgbthreshold = 170;
gbrthreshold = 190;
bgrthreshold = 190;


%Read Image
webCam = imread("crossMarker.jpeg");
imSize = size(webCam);


%Create red, green, blue, black, and white images from thresholds 

red= webCam(:,:,1) > rthreshold & webCam(:,:,2) < rgbthreshold & webCam(:,:,3) < rgbthreshold;

green = webCam(:,:,1) < gbrthreshold & webCam(:,:,2) > gthreshold & webCam(:,:,3) < gbrthreshold;

blue = webCam(:,:,1) < bgrthreshold & webCam(:,:,2) < bgrthreshold & webCam(:,:,3) > bthreshold;

black = webCam(:,:,1) < threshold & webCam(:,:,2) < threshold & webCam(:,:,3) < threshold;

white = webCam(:,:,1) > threshold & webCam(:,:,2) > threshold & webCam(:,:,3) > threshold;


%Area search around pixel
sweep = 3; 

%Initialize matrices 
greenWhite = zeros(imSize(1),imSize(2),sweep+1);
greenRed = zeros(imSize(1),imSize(2),sweep+1);

redGreen = zeros(imSize(1),imSize(2),sweep+1);
redBlue = zeros(imSize(1),imSize(2),sweep+1);
redBlack = zeros(imSize(1),imSize(2),sweep+1);

blueRed = zeros(imSize(1),imSize(2),sweep+1);
blueWhite = zeros(imSize(1),imSize(2),sweep+1);

whiteBlue = zeros(imSize(1),imSize(2),sweep+1);
whiteGreen = zeros(imSize(1),imSize(2),sweep+1);
whiteBlack = zeros(imSize(1),imSize(2),sweep+1);

allBound = zeros(imSize(1),imSize(2),sweep+1);
allBound2 = zeros(imSize(1),imSize(2),sweep+1); 
allBound3 = zeros(imSize(1),imSize(2),sweep+1);
allBound4 = zeros(imSize(1),imSize(2),sweep+1);

allBound = logical(allBound);
allBound2 = logical(allBound2);
allBound3 = logical(allBound3);
allBound4 = logical(allBound4);


%find where colour change occurs on the same pixel
for i = 1:imSize(1)
    
    for j = 1:imSize(2)
        if green(i,j) == 0
            
        else 
            greenWhite(i,j,1) = white(i,j);    
            greenRed(i,j,1) = red(i,j);
        end
        
        if red(i,j) == 0 
            
        else 
            redGreen(i,j,1) = green(i,j);
            redBlue(i,j,1) = blue(i,j);
            redBlack(i,j,1) = black(i,j);
        end
        
        if blue(i,j) == 0
            
        else
            blueRed(i,j,1) = red(i,j); 
            blueWhite(i,j,1) = white(i,j);
        end
        
        if white(i,j) == 0 
            
        else
            whiteBlue(i,j,1) = blue(i,j);     
            whiteGreen(i,j,1) = green(i,j);
            whiteBlack(i,j,1) = black(i,j);
        end
    end
end


%find colour change within an increasing number of pixels
for s = 1:sweep
    n = s;
    nn = s + 1;
    for i = nn:imSize(1)-nn
        for j = nn:imSize(2)-nn
        
            if green(i,j) == 0
            
            else 
                greenWhite(i,j,n+1) = max(max((white(i-n:i+n,j-n:j+n))));    
                greenRed(i,j,n+1) = max(max((red(i-n:i+n,j-n:j+n))));
            end
        
            if red(i,j) == 0 
            
            else 
                redGreen(i,j,n+1) = max(max((green(i-n:i+n,j-n:j+n))));
                redBlue(i,j,n+1) = max(max((blue(i-n:i+n,j-n:j+n))));
                redBlack(i,j,n+1) = max(max((black(i-n:i+n,j-n:j+n))));
            end
        
            if blue(i,j) == 0
            
            else
                blueRed(i,j,n+1) = max(max((red(i-n:i+n,j-n:j+n)))); 
                blueWhite(i,j,n+1) = max(max((white(i-n:i+n,j-n:j+n))));
            end
        
            if white(i,j) == 0 
            
            else
                whiteBlue(i,j,n+1) = max(max((blue(i-n:i+n,j-n:j+n))));     
                whiteGreen(i,j,n+1) = max(max((green(i-n:i+n,j-n:j+n))));
                whiteBlack(i,j,n+1) = max(max((black(i-n:i+n,j-n:j+n))));
            end
        
        end
    end
end

%combine colour boundaries in differing ways to comapre noise
for i = 1:sweep+1
    
    allBound(:,:,i) = greenWhite(:,:,i) | greenRed(:,:,i) | redGreen(:,:,i) | redBlue(:,:,i) |...
        redBlack(:,:,i) | blueRed(:,:,i) | blueWhite(:,:,i) | whiteBlue(:,:,i) |...
        whiteGreen(:,:,i) | whiteBlack(:,:,i);

    allBound2(:,:,i) = greenWhite(:,:,i) | greenRed(:,:,i) | redGreen(:,:,i) | redBlue(:,:,i) |...
        redBlack(:,:,i) | blueRed(:,:,i) | blueWhite(:,:,i);

    allBound3(:,:,i) = greenRed(:,:,i) | redGreen(:,:,i) | redBlue(:,:,i) | redBlack(:,:,i) | blueRed(:,:,i);

    allBound4(:,:,i) = greenRed(:,:,i) | redGreen(:,:,i) | redBlue(:,:,i) | blueRed(:,:,i);
    
end


%plot combined edge maps
figure 
subplot(2,2,1), imshow(allBound(:,:,1))
subplot(2,2,2), imshow(allBound(:,:,2))
subplot(2,2,3), imshow(allBound(:,:,3))
subplot(2,2,4), imshow(allBound(:,:,4))


figure 
subplot(2,2,1), imshow(allBound2(:,:,1))
subplot(2,2,2), imshow(allBound2(:,:,2))
subplot(2,2,3), imshow(allBound2(:,:,3))
subplot(2,2,4), imshow(allBound2(:,:,4))

figure 
subplot(2,2,1), imshow(allBound3(:,:,1))
subplot(2,2,2), imshow(allBound3(:,:,2))
subplot(2,2,3), imshow(allBound3(:,:,3))
subplot(2,2,4), imshow(allBound3(:,:,4))


figure 
subplot(2,2,1), imshow(allBound4(:,:,1))
subplot(2,2,2), imshow(allBound4(:,:,2))
subplot(2,2,3), imshow(allBound4(:,:,3))
subplot(2,2,4), imshow(allBound4(:,:,4))