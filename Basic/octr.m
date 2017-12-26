function octr(op)

global m H imgrz imagen30 gblack  imgsav gaus rgbimg imagengro ...
   grayimg grayimg2 se bwimg im_r im_c edgimg L Ne%variables used (inter progs)

if nargin == 0 % if no input argument, draw the GUI
	op = 0;
end

width = 800;
height = 600;

switch op 
	
%--------------------------------------------------------------------------
    
    case 0 % Draw figure
	close all;
	count = 0;
	s = get(0,'ScreenSize');

        
        se=strel('disk',1);      %disk mask
            
% -------------------------------------------------------------------------
% --------------------------------  FIGURE & MENUS  -----------------------
	H.fig = figure('Position',...
        [(s(3)-width)/2 (s(4)-height)/2 width height],...
		'NumberTitle','off',...
		'MenuBar','none',...
		'Color',[.255 .255 .255],...
		'Name','Txt image enhancer');
	
	H.menu(1) = uimenu(H.fig,'Label','&Load-pic');
	H.menu(2) = uimenu(H.menu(1),'Label','&Open',...
		'Callback','octr(1)');
	H.menu(3) = uimenu(H.fig,'Label','&Data');	
	H.menu(4) = uimenu(H.menu(3),'Label','&Save',...
		'Callback','octr(13)');
	
	% ---------------------------------------------------------------------
	% ---------------------------------  IMAGE FRAME  ---------------------
	
    H.ax(1) = axes('position',...
        [20/width 20/height 0.5+25/width 1-60/height],...
        'Color',[1 1 1],...
		'XTick',[],'YTick',[],'Box','on');
	
	        uicontrol('Style','text',... %
		'BackgroundColor',[.5 .7 .8],...
		'Units','normalized',...
		'Position',[20/width (height-30)/height 0.5+25/width 20/height],...
		'String','CROP RECOMMENDATION SYSTEM',...
		'HorizontalAlignment','center',...
		'FontSize',13);
	
       
       
	% ---------------------------------------------------------------------
	% -------------------------  selection button FRAME  ------------------	
	
	
    uicontrol('Style','frame',...
		'Units','normalized',...
        'BackgroundColor',[.51 .51 .255],...
		'Position',[480/width 20/height 300/width 1-32/height]);
	
	
	
      H.button(1) = uicontrol('Style','pushbutton',... 
       'BackgroundColor',[.8 .8 0],...
      'Units','normalized', ...
      'Position',[550/width (height-50)/height 200/width 30/height],...
       'FontSize',10,...
      'String','RGB to Grey',...
      'HorizontalAlignment','left',...
      'CallBack','octr(2)');
	

	  H.button(2) = uicontrol('Style','pushbutton',... 
      'Units','normalized', ...
      'BackgroundColor',[.8 .8 0],...
      'Position',[550/width (height-100)/height 200/width 30/height],...
      'FontSize',10,...
      'String','Erode filter',...
      'HorizontalAlignment','left',...
      'CallBack','octr(3)');
	
  
      H.button(3) = uicontrol('Style','pushbutton',... 
      'Units','normalized', ...
      'BackgroundColor',[.8 .8 0],...
      'Position',[550/width (height-150)/height 200/width 30/height],...
      'FontSize',10,...
      'String','Midstretch filter',...
      'HorizontalAlignment','left',...
      'CallBack','octr(4)');

	
      H.button(4) = uicontrol('Style','pushbutton',...
		'Units','normalized',...
        'BackgroundColor',[.8 .8 0],...
		'Position',[550/width (height-200)/height 200/width 30/height],...
         'FontSize',10,...
        'String','Median filter',...
		'HorizontalAlignment','left',...
		'CallBack','octr(5)');
     
    
      H.button(5) = uicontrol('Style','pushbutton',...
		'Units','normalized',...
        'BackgroundColor',[.8 .8 0],...
		'Position',[550/width (height-250)/height 200/width 30/height],...
        'FontSize',10,...
        'String','Gray-dilate filter',...
		'HorizontalAlignment','left',...
		'CallBack','octr(6)');
           
    
      H.button(6) = uicontrol('Style','pushbutton',...
		'Units','normalized',...
        'BackgroundColor',[.8 .8 0],...
		'Position',[550/width (height-300)/height 200/width 30/height],...
        'FontSize',10,...
        'String','Sharpen filter',...
		'HorizontalAlignment','left',...
		'CallBack','octr(7)');
        
     
      H.button(7) = uicontrol('Style','pushbutton',...
		'Units','normalized',...
        'BackgroundColor',[.8 .8 .0],...
		'Position',[550/width (height-340)/height 40/width 30/height],...
        'FontSize',10,...
        'String','NA',...
		'HorizontalAlignment','left',...
		'CallBack','octr(8)');
            
        
      H.button(9) = uicontrol('Style','pushbutton',...
		'Units','normalized',...
        'BackgroundColor',[.8 .8 .0],...
		'Position',[600/width (height-340)/height 40/width 30/height],...
        'FontSize',10,...
        'String','B/W ',...
		'HorizontalAlignment','left',...
		'CallBack','octr(9)');     
                
     
      H.button(8) =  uicontrol('Style', 'slider',...
        'Min',-.5,'Max',.5,'Value',0,...
         'SliderStep',[0.1 0.6],...
         'BackgroundColor',[.8 .8 .0],...
        'Position', [650 265 120 20],...
        'Callback', 'octr(9)');
                 
           
      H.button(10) = uicontrol('Style','pushbutton',...
		'Units','normalized',...
        'BackgroundColor',[.8 .8 .0],...
		'Position',[550/width (height-390)/height 100/width 30/height],...
        'FontSize',10,...
        'String','Noise Removal',...
		'HorizontalAlignment','left',...
		'CallBack','octr(10)');
              
         
      H.button(11) = uicontrol('Style','pushbutton',...
		'Units','normalized',...
        'BackgroundColor',[.8 .8 .0],...
		'Position',[550/width (height-460)/height 100/width 50/height],...
        'FontSize',10,...
        'String','Segment It',...
		'HorizontalAlignment','left',...
		'CallBack','octr(11)');
      
  
      H.button(12) = uicontrol('Style','pushbutton',...
		'Units','normalized',...
        'BackgroundColor',[.8 .8 .0],...
		'Position',[550/width (height-530)/height 100/width 60/height],...
        'FontSize',10,...
        'String','Edge Detect',...
		'HorizontalAlignment','left',...
		'CallBack','octr(12)');
        
            
      	% -----------------------------------------------------------------
	% -----------------------------  cases   ------------------------------

%--------------------------------------------------------------------------
    case 1 % Read and display an image
	
        [filename,pathname] = uigetfile({'*.tif;*.jpg;*.png','Image files'});
		
        if filename ~= 0
		% Clear the old data
		
        
		% Read the image and convert to intensity	
        rgbimg = imread([pathname filename]);
		figure,imshow(rgbimg),title('Your selected RGB-pic')
        end

%--------------------------------------------------------------------------

    case 2 % Convert to gray scale
    
        if size( rgbimg,3)==3 %RGB image
   
        grayimg=rgb2gray(rgbimg);

        end

        r_max = 700;
		c_max = 600;
		[r1,c1] = size(grayimg);
        
		[im_r,im_c] = fit_im(r_max,c_max,r1,c1)

        grayimg=imresize(grayimg,[im_r,im_c],'nearest');
     
        figure,imshow(grayimg),title ( ' gray scale image')
        grayimg2=grayimg;
        
           imgsav=grayimg2;

%--------------------------------------------------------------------------
    
    case 3	 % erode filter..se mask globaly declared
    
        
        grayimg2=imerode(grayimg2,se); 
        
        figure,imshow(grayimg2),title('eroded')
        
            imgsav=grayimg2;
%--------------------------------------------------------------------------

   
    case 4   % mid stretchig filter.

        
        x1=double(grayimg2)/255; % x1 range to 0 and 1
        y=(0.5*x1).*[x1<0.2]+(0.1+1.5*(x1-0.2)).*[0.2 <= x1 & x1 <= 0.7] ...
           +(1+0.5*(x1-1)).*[x1 > 0.7];


       [xmid,indy]=cmunique(y);
       
       grayimg2=ind2gray(xmid,indy);
       figure,imshow(grayimg2),title('mid strecched')
       
    imgsav=grayimg2;
%--------------------------------------------------------------------------
    case 5   % median filte..
    
        
        grayimg2=medfilt2(grayimg2,'symmetric');

        figure,imshow(grayimg2); title('median filtering ')
    imgsav=grayimg2;
 
%--------------------------------------------------------------------------
  
    case 6   %gray-dilate filter
    

        grayimg2=imdilate(grayimg2,se);

        figure,imshow(grayimg2);title('gray-dilated')
 
    imgsav=grayimg2;
%--------------------------------------------------------------------------
  
    case 7                           %6filtering second
                                   w4=fspecial('laplacian',0);
                                    f=im2double(grayimg2);
                                 grayimg2=f-imfilter(f,w4,'replicate');
                                           
                          figure,imshow(grayimg2);title('filtering second')
                                     
                                     
                                        imgsav=grayimg2;
                                     
                                     
                                     
                                     
                                     
                                     
                                     
       
 
%--------------------------------------------------------------------------

 
    case 8	% plotting intensity distri

    y=[zeros(1,256)];

    [r,c]=size(grayimg2)

    for j=1:1:r
    
        for k=1:1:c
    
            for q=1:1:256
    
                if grayimg2(j,k)==q
        
                    y(q)=y(q)+1;
    
                end

            end

        end

    end

    figure,plot(y);

%--------------------------------------------------------------------------	



   
    case 9   % displaying b/w %%%%%%
        
   
        m= get(H.button(8),'Value')
   
        threshold = graythresh(grayimg2);

        threshold=threshold+m;threshold 
      
        bwimg =~im2bw(grayimg2,threshold);figure,imshow(bwimg);title('b/w')
   
   imgsav=bwimg;
   
%--------------------------------------------------------------------------	

  
    case 10   % Remove all object containing fewer than 5 pixels,dilate & then.those<30

        imagen5 = bwareaopen(bwimg,5);

        figure,imshow(imagen5); title('delete islands size< 5')
          imgsav=imagen5;
        %dilate
        b=[1,1,1];

        imagengro=imdilate(imagen5,b);%chg edgimg to imagen5

        figure,imshow(imagengro); title('dilated')

        % Remove all object containing fewer than 30 pixels
        
        imagen30 = bwareaopen(imagengro,30);

        figure,imshow(imagen30); title('delete islands size < 30')

        imgsav=imagen30;

%--------------------------------------------------------------------------	

    case 11   %segmenting..................................................
      
        gblack=imagen30-imagen30;%figure,imshow(gblack);  %for black background.
        % Label and count connected components
        
        [L Ne] = bwlabel(imagen30); Ne   
   
        for n=1:Ne      %dragon loop.........starts.....     
      
            [r,c] = find(L==n);
  
        
       
            ra=min(r);rb=max(r);ca=min(c);cb=max(c);
            
            %gseg=imagen30(ra:rb,ca:cb);      
            gsego=grayimg(ra:rb,ca:cb);      
       
       
      % gd=imdilate(gsego,se);figure,imshow(gd);title('gray op 1.dil')
       
      gd =imerode(gsego,se);%figure,imshow(gd);title('ero seg')
       
       

threshold = graythresh(gd);
gsegbw =~im2bw(gd,threshold);%figure,imshow(gsegbw);title('b/w segment') 
 
 
  for i=min(r):max(r)
        for j=min(c):max(c)
            gblack(i,j)=gsegbw((i-min(r)+1),(j-min(c)+1));
        end
        figure,imshow(gblack);
  end



        end
    figure,imshow(~gblack); title('b/w-segment joined o/p');  % ..it works!!..smtimes.. 
   % ra=rt/Ne;ca=ct/Ne;ra,ca

   %dilate
b=[1;1;1];
imagengro=~imdilate(gblack,b);

   figure,imshow(imagengro); title('b/w-segment joined dilated o/p')
   imgsav=imagengro;
%}


%--------------------------------------------------------------------------
case 12 %edge detect

 th=.015;%,th after roberts 4 manu
        edgimg = edge(grayimg2,'roberts');
        figure,imshow(edgimg);title( 'edge plot1')
        imgsav=edgimg;
        edgimg = bwareaopen(edgimg,2);
 %dilate
        b=[1;1;1];

        imagengro2=imdilate(edgimg,b);%chg edgimg to imagen5

        figure,imshow(imagengro2); title('dilated 2')
        
        imagengro2 = bwareaopen(imagengro2,50);

       figure,imshow(imagengro2); title('delete islands size< 35-3')
        
  %dilate2
        b=[1;1;1;1;1;1;1;1;1];

        imagengro2=imdilate(edgimg,b);%chg edgimg to imagen5

        figure,imshow(imagengro2); title('dilated 2-4')
       
       imagengro2 = bwareaopen(imagengro2,50);

       figure,imshow(imagengro2); title('delete islands size< 50-5')
       
 %dilate3
        b=[1,1,1];

       imagengro2=imdilate(imagengro2,b);%chg edgimg to imagen5

 imagen30= bwareaopen(imagengro2,500);
  
        [L Ne] = bwlabel(imagen30); Ne   

       figure,imshow(imagen30); title('delete islands -6');

        
   
        

         

%--------------------------------------------------------------------------
    
  
    
    case 13 % Save Image and feature data to a file
	
	imwrite(imgsav,'zzbw.jpg');

%--------------------------------------------------------------------------
    
%------------------------------------------%%case ends---------------------
     
end      
       
        



% Sub-functions

%--------------------------------------------------------------------------


function [im_r,im_c] = fit_im(r_max,c_max,r1,c1)
% Resize the image accordingly

r_ratio = r1/r_max;
c_ratio = c1/c_max;

if (r_ratio > 1) | (c_ratio > 1)
	if r_ratio > c_ratio
		im_r = r_max;
		im_c = c1/r_ratio;
	else
		im_c = c_max;
		im_r = r1/c_ratio;			
	end
else
	im_r = r1;
	im_c = c1;
end


%--------------------------------------------------------------------------



