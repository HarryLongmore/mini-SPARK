%This function Generates hough lines and finds the center of the X


%Generate hough lines
[H,T,R] = hough(allBound3(:,:,3))
P  = houghpeaks(H,100,'Threshold',0.3*max(H(:)),'NHoodSize',[1 1]);
%Find Hough lines
lines = houghlines(allBound4(:,:,2),T,R,P,'MinLength',20);


%Initialize variables
voteSpace = zeros(inputSize(1),inputSize(2));
solutionSpace = zeros(inputSize(1),inputSize(2));
max_len = 0;
scale = 100;
localScale = scale/10;

for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   %Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   %Plot points on vote space 
   voteSpace(xy(1,2),xy(1,1)) = voteSpace(xy(1,2),xy(1,1)) + 1;
   voteSpace(xy(2,2),xy(2,1)) = voteSpace(xy(2,2),xy(2,1)) + 1;
   
   %Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end



% find location of 3 strongest candidtes 
i = 0;

while i < 3
    %checks for candidate 
    centerCand = find(voteSpace == max(max(voteSpace)))
    [row,col] = ind2sub(inputSize(1:2),centerCand);
    if length(centerCand) == 1
    
        
        plot(col,row,'x','LineWidth',2,'Color','green');
        voteSpace(row-scale:row+scale,col-scale:col+scale) = 0;
        solutionSpace(row,col) = 1;
        i = i + 1
    else 
    %removes area around found candidate     
    voteSpace(row-localScale:row+localScale,col-localScale:col+localScale) = 0;
    
    end 
end


