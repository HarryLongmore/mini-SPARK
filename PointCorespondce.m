%This script finds the point corespondce for vertical and horeztonal line
%corespindce 

%From output "centroidHor" and "centroidVert" as matrices with line
%correspondce 

%Initialize holding vairables
vertSize = size(centroidVert);
horSize = size(centroidHor);

centroidVert = logical(centroidVert);
centroidHor = logical(centroidHor);

PointMatrix = zeros(horSize(3),horSize(3));
DotMatrix = zeros(horSize(1),horSize(2));
DotMatrix = logical(DotMatrix);


for i = 1:horSize(3)
    for j = 1:vertSize(3)
        
        %Finds the intersection by finding matching point
        pointHold = centroidHor(:,:,i) & centroidVert(:,:,j);
       
        %If there is no matching point set to 0
        subPoint = find(pointHold);
        subPoint(isempty(subPoint))= 0;
        
        %If there is multiple matching points the mean linear index
        %position is slected as the true point
        meanSubPoints = mean(subPoint);
        
        %stores linear index of point
        CamPointMatrix(i,j) = meanSubPoints;
        
       
    end  
end