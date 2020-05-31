%This script generates Horizontal grey code and finds line correspondce for
%a set of given images with the projected grey code

%This code can be edited to create vertical Grey code by changing disph to
%dispv in the printIm line and can find vertical corespondce by chaning the
%sobel filter to a vertical one

%Sets the number of patterns of greycode used in finding corespondcne
%this can differ due to the quality of images of the scene
nopat = 7;

%Sets the number of grey code patterns generated
rows = 8; 
n = 2^rows - 1;

%sets the vertical pixel length of the grey code for resolution scaling
vecRep = 408;


%Gnerates Grey code from binary
b = zeros(n,length(de2bi(n)));
c = b;

for i = 1:n
    biArray = de2bi(i);
    len = length(biArray);
    b(i,1:len) = de2bi(i);   
end
c(:,1:end-1) = b(:,2:end);
grey = xor(b,c);

%Appends alternating stripe pattern to end
grey2 = [b(:,1),grey];


%Print and save grey code
%change the commented out imwrite function to save 
for i = 1:rows+1
    
    disph(:,:,i) = repmat(grey2(:,i),1,vecRep);
    dispv(:,:,i) = repmat(grey2(:,i),1,vecRep)';
    
end    

genfile = 'HorizontalGreyCode';
endfile = '.jpeg';

for i = 1:rows+1
   number = num2str(i);
   filename = strcat(genfile,number,endfile);   
   size(dispv(:,:,rows+2-i))
   %Change disph to dispv for vertical images
   %imshow(disph(:,:,rows+2-i)),imwrite(dispv(:,:,rows+2-i),filename)
end



%Find corespondce of projected grey code

%Read images of grey code 
%CHNAGE FILE NAME HERE
genfile = 'HorTea';
endfile = '.jpg';

%Create white and black images of each image from threshold 

threshBlackMax = 100; %max(max(bwCalB));
threshWhiteMin = 150; %min(min(bwCalW));

%Initialise holding variables 
calsize = imread(strcat(genfile,'1',endfile));
imSize = size(calsize);
shot = zeros(imSize(1),imSize(2),nopat);
black = shot;
white = shot;
shot = uint8(shot);


for i=1:nopat
    
    number = num2str(i);
    filename = strcat(genfile,number,endfile);
    shot(:,:,i)= rgb2gray(imread(filename));
    
    black(:,:,i) = shot(:,:,i) <= threshBlackMax;
    white(:,:,i) = shot(:,:,i) >= threshWhiteMin;
    
    %Test threshold images
    %figure, subplot(2,1,1), imshow(black(:,:,i))
    %subplot(2,1,2), imshow(white(:,:,i))
end

%Find stripe corespondance 

%Intitalize sorting variables
grayPatterns = size(grey2);
line = ones(imSize(1),imSize(2),grayPatterns(1));
line = logical(line); 
total = zeros(imSize(1),imSize(2));


%Finds code for each stripe and compares it to the image set
for i = 1:grayPatterns(1)
    
    for j = 1:nopat
    
        hold = not(xor(white(:,:,j),grey2(i,rows+2-j)));
        line(:,:,i) = hold & line(:,:,i);
        imshow(line(:,:,i))
    end
   
    total = total | line(:,:,i);
end

figure,imshow(total) 


%Find line corespondnce          

%Initialize holding variables
centroidHor = zeros(imSize(1),imSize(2),size(line,3)-1);
collectCent = zeros(imSize(1),imSize(2));

for i = 1:size(line,3)-2
   
    %Chnage sobel for vertical corespondce 

   %Filters gaussian noise
   filtered = medfilt2(line(:,:,i));
   %Find edge of first stripe from sobel
   s = edge(filtered,'Sobel','horizontal');
   
   %Find edge of second stripe from sobel
   filtered = medfilt2(line(:,:,i+2));
   s1 = edge(filtered,'Sobel','horizontal');
   
   %Line corespondce found at matching edges between images
   %Change to centroidVer for vertical 
   centroidHor(:,:,i) = s1&s;

  
end
