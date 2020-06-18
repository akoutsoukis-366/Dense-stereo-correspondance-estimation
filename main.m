
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                %
%                        
%     Dense stereo correspondance estimation     %
%                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear ;
clc;



% define window size 
prompt = {'Enter window size:'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'9'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
windowSize=str2double(answer(1,1));



%read the left and right images
Im_left=imread('im2.png');
Im_right=imread('im6.png');

%make them black and white
Im_left=double(rgb2gray(Im_left));
Im_right=double(rgb2gray(Im_right));


% find the size of the image
[rows,columes]=size(Im_left);

% create an empy matrix same size to image.
dispmap = zeros((rows), (columes));


% go through all rows of the image. starting from the row that is half
% window size away from the first row and ends to the one that is half
% window size away from the last row
for i=round(windowSize/2):rows-round(windowSize/2);
    % do the same for all columes 
    for j=round(windowSize/2):columes-round(windowSize/2);
        
         % create an window that goes through the hole image. 
            Window=Im_right(i-round(windowSize/2)+1:i+round(windowSize/2)-1,j-round(windowSize/2)+1:j+round(windowSize/2)-1);
           
          
        
              
        maxcost=inf;
        % go through the colume defined earlier up to 60 columes to the
        % right of this colume.
        if j+59+round(windowSize/2)<columes
        for  k=j:j+60;
            % create another window that for each place of the first window
            % will go up to 60 columes to the right of the colume of the
            % first window 
            Window_Try=Im_left(i-round(windowSize/2)+1:i+round(windowSize/2)-1,k-round(windowSize/2)+1:k+round(windowSize/2)-1);

        % calculate cost between the 2 windows in every step of second
        % window using SAD method
            %cost=sum(sum(abs(Window_Try-Window)));
        % calculate cost usind SSD method
            cost=sum(sum((Window_Try-Window).^2));
        
          
            
          % find the minumun cost for each central window of the first
          % image compeared with the 60 windows of the second image
          
            if cost<maxcost
               maxcost=cost;
               % find the place of each central pixel of the second window
               % with minumum cost and substract the place of the initial  
               % central pixel of the first window. Save that value in the
               % same place as for the initial central pixel of the first
               % window
               dispmap(i,j)=(k-j)*4;   
            end
             
        end
        % this case is the same as before but it's for the pixel that are
        % less than 60 pixel to the end of the image
        else
            for  k=j:j+(450-j)-round(windowSize/2);
            Window_Try=Im_left(i-round(windowSize/2)+1:i+round(windowSize/2)-1,k-round(windowSize/2)+1:k+round(windowSize/2)-1);

        
           
            %cost=sum(sum(abs(Window_Try-Window)));
           
            cost=sum(sum((Window_Try-Window).^2));
          
            
            
                 if cost<maxcost
                    maxcost=cost;
                    dispmap(i,j)=(k-j)*4;   
                end
            
             end
               
        end
        
    end
     
end
% show the image and cut the black pixels that we cant find the disparity
% for them. 
dispmap=dispmap(round(windowSize/2):rows-round(windowSize/2),round(windowSize/2):columes-round(windowSize/2));
subplot(2,2,1),imshow(mat2gray(dispmap));
title('Disparity Map');


% read the ground truth depth map and cut edge rows and columes to be the
% same as the dispmap image
disp6=double(imread('disp6.png'));
disp6=disp6(round(windowSize/2):rows-round(windowSize/2),round(windowSize/2):columes-round(windowSize/2));
subplot(2,2,2),imshow(mat2gray(disp6));
title('Ground Truth Depth Map');

% compare the groun trouth with the calculated disparity map by their
% difference in pixel
diff=disp6-dispmap;
subplot(2,2,3),imshow(mat2gray(diff));
title('Difference by Subtracting Pixel Values');


% compare the groun trouth with the calculated disparity map by using
% matlabs 'diff' which creates a difference image from A and B.
subplot(2,2,4),imshowpair(disp6,dispmap,'diff');
title('Difference by Using Diff');

%calculating the corelation using the Pearson correlation to 2-D arrays
c = corr2(disp6,dispmap);
suptitle(['Correlation is ' num2str(c) ' for window size ' num2str(windowSize) ' pixels'] )


