% Tuto RDK
% http://www.mbfys.ru.nl/~robvdw/DGCN22/PRACTICUM_2011/LABS_2011/ALTERNATIVE_LABS/Lesson_2.html
clear
close all
%%

dots.nDots = 100;                % number of dots
dots.color = [255,255,255];      % color of the dots
dots.size = 4;                   % size of dots (pixels)
dots.center = [0,0];           % center of the field of dots (x,y)
dots.apertureSize = [12,12];     % size of rectangular aperture [w,h] in degrees.

dots.x = (rand(1,dots.nDots)-.5)*dots.apertureSize(1) + dots.center(1);
dots.y = (rand(1,dots.nDots)-.5)*dots.apertureSize(2) + dots.center(2);

%%
figure(1)
clf
%draw the aperture
patch([-.5,-.5,.5,.5]*dots.apertureSize(1)+dots.center(1), ...
    [-.5,.5,.5,-.5]*dots.apertureSize(2)+dots.center(2),[.8,.8,.8]);
hold on
plot(dots.x,dots.y,'ko','MarkerFaceColor','b');

xlabel('X (deg)');
ylabel('Y (deg)');
axis equal
%%

display.dist = 57;  %cm
display.width = 30; %cm

tmp = Screen('Resolution',0);
display.resolution = [tmp.width,tmp.height];

%% anonymous function:
%f = @(arglist)expression
% angle2pix = @(d, x) 2*tan(x./(2*d));
% angle2pix = @(d, x) x;

% pixpos.x = angle2pix(display.dist,dots.x);
% pixpos.y = angle2pix(display.dist,dots.y);

pixpos.x = angle2pix(display,dots.x);
pixpos.y = angle2pix(display,dots.y);

% pixpos.x = dots.x;
% pixpos.y = dots.y;

% This generates pixel positions, but they're centered at [0,0].  The last
% step for this conversion is to add in the offset for the center of the
% screen:
pixpos.x = pixpos.x + display.resolution(1)/2;
pixpos.y = pixpos.y + display.resolution(2)/2;

%% We can make a similar plot of the pixel positions:
figure(2)
clf
plot(pixpos.x,pixpos.y,'ko','MarkerFaceColor','b');
% set(gca,'XLim',[0,display.resolution(1)]);
% set(gca,'YLim',[0,display.resolution(2)]);
xlabel('X (pixels)');
ylabel('Y (pixels)');
axis equal

%% The 'DrawDots' command
try
    win.skipChecks=1;
    %     display = OpenWindow(display);
    % Open or close a window or texture:
    % [windowPtr,rect]=Screen('OpenWindow',windowPtrOrScreenNumber [,color] [,rect] [,pixelSize] [,numberOfBuffers] [,stereomode] [,multisample][,imagingmode][,specialFlags][,clientRect]);
    win.windowPtrOrScreenNumber = max(Screen('Screens'));
    win.windowPtr = Screen('OpenWindow', win.windowPtrOrScreenNumber, .35);
    display.frameRate = 1/Screen('GetFlipInterval', win.windowPtr);
    % Screen('Preference', 'SkipSyncTests', 1);
    
    Screen('DrawDots',win.windowPtr,[pixpos.x;pixpos.y], dots.size, dots.color,[0,0],1);
    Screen('Flip',win.windowPtr);
    pause(2)
catch ME
    Screen('CloseAll');
    rethrow(ME)
end
Screen('CloseAll');


%% Our First Animation
% dots.nDots = 10;                % number of dots
% dots.color = [255,255,255];      % color of the dots
% dots.size = 4;                   % size of dots (pixels)
% dots.center = [0,0];           % center of the field of dots (x,y)
% dots.apertureSize = [12,12];     % size of rectangular aperture [w,h] in degrees.

dots.speed = 3;       %degrees/second
dots.duration = 5;    %seconds
dots.direction = 30;  %degrees (clockwise from straight up)

%% init
pixpos.x = [];
pixpos.y = [];
% display.frameRate = 1/Screen('GetFlipInterval', win.windowPtr);
dx = dots.speed*sin(dots.direction*pi/180)/display.frameRate; 
dy = -dots.speed*cos(dots.direction*pi/180)/display.frameRate;

dots.x = (rand(1,dots.nDots)-.5)*dots.apertureSize(1) + dots.center(1);
dots.y = (rand(1,dots.nDots)-.5)*dots.apertureSize(2) + dots.center(2);
% motion = [1, 1];
% dx = dots.speed * motion(1) / display.frameRate;
% dy = dots.speed * motion(2) / display.frameRate;

secs2frames = @(frameRate, duration) ceil(duration * frameRate);

nFrames = secs2frames(display.frameRate, dots.duration);

%% animation
try
    %     display = OpenWindow(display);
    win.windowPtrOrScreenNumber = max(Screen('Screens'));
    win.windowPtr = Screen('OpenWindow', win.windowPtrOrScreenNumber, .35);
    
    for i=1:nFrames
        %convert from degrees to screen pixels
        pixpos.x = [pixpos.x ; angle2pix(display,dots.x(i,:))+ display.resolution(1)/2];
        pixpos.y = [pixpos.y ; angle2pix(display,dots.y(i,:))+ display.resolution(2)/2];
%         pixpos.x = [pixpos.x ; angle2pix(display.dist,dots.x(i,:))+ display.resolution(1)/2];
%         pixpos.y = [pixpos.y ; angle2pix(display.dist,dots.y(i,:))+ display.resolution(2)/2];
        
        Screen('DrawDots',win.windowPtr,[pixpos.x(i,:);pixpos.y(i,:)], dots.size, dots.color,[0,0],1);
        %update the dot position
%         dx = dots.speed*sin(i.*dots.direction*pi/180)/display.frameRate; 
%         dy = -dots.speed*cos(i.*dots.direction*pi/180)/display.frameRate;

        dots.x = [dots.x; dots.x(i,:) + dx];
        dots.y = [dots.y; dots.y(i,:) + dy];
        
        Screen('Flip',win.windowPtr);
    end
catch ME
    Screen('CloseAll');
    rethrow(ME)
end
Screen('CloseAll');

%% visu
% figure(3)
% hold on
% for j = 1 : nFrames
%     plot(dots.x(j,:), dots.y(j,:), 'ko')
%     plot(pixpos.x(j,:), pixpos.y(j,:), 'bo')
%     pause(.03)
% end
% hold off
%%
% figure(4)
% hold on
% plot(dots.x)
% plot(dots.y)
% plot(pixpos.x)
% plot(pixpos.y)
% hold off

%% Keeping the Dots in the Aperture
l = dots.center(1)-dots.apertureSize(1)/2;
r = dots.center(1)+dots.apertureSize(1)/2;
b = dots.center(2)-dots.apertureSize(2)/2;
t = dots.center(2)+dots.apertureSize(2)/2;

dots.x = (rand(1,dots.nDots)-.5)*dots.apertureSize(1) + dots.center(1);
dots.y = (rand(1,dots.nDots)-.5)*dots.apertureSize(2) + dots.center(2);

try
%     display = OpenWindow(display);
    win.windowPtrOrScreenNumber = max(Screen('Screens'));
    win.windowPtr = Screen('OpenWindow', win.windowPtrOrScreenNumber, .35);
    for i=1:nFrames
        %convert from degrees to screen pixels
        pixpos.x = angle2pix(display,dots.x)+ display.resolution(1)/2;
        pixpos.y = angle2pix(display,dots.y)+ display.resolution(2)/2;
%         pixpos.x = angle2pix(display.dist,dots.x)+ display.resolution(1)/2;
%         pixpos.y = angle2pix(display.dist,dots.y)+ display.resolution(2)/2;

        Screen('DrawDots',win.windowPtr,[pixpos.x;pixpos.y], dots.size, dots.color,[0,0],1);
        %update the dot position
        dots.x = dots.x + dx;
        dots.y = dots.y + dy;

        %move the dots that are outside the aperture back one aperture
        %width.
        dots.x(dots.x<l) = dots.x(dots.x<l) + dots.apertureSize(1);
        dots.x(dots.x>r) = dots.x(dots.x>r) - dots.apertureSize(1);
        dots.y(dots.y<b) = dots.y(dots.y<b) + dots.apertureSize(2);
        dots.y(dots.y>t) = dots.y(dots.y>t) - dots.apertureSize(2);

        Screen('Flip',win.windowPtr);
    end
catch ME
    Screen('CloseAll');
    rethrow(ME)
end
Screen('CloseAll');

%% Limited Lifetime Dots

dots.lifetime = 12;  %lifetime of each dot (frames)

% First we'll calculate the left, right top and bottom of the aperture (in
% degrees)
l = dots.center(1)-dots.apertureSize(1)/2;
r = dots.center(1)+dots.apertureSize(1)/2;
b = dots.center(2)-dots.apertureSize(2)/2;
t = dots.center(2)+dots.apertureSize(2)/2;

% New random starting positions
dots.x = (rand(1,dots.nDots)-.5)*dots.apertureSize(1) + dots.center(1);
dots.y = (rand(1,dots.nDots)-.5)*dots.apertureSize(2) + dots.center(2);

% Each dot will have a integer value 'life' which is how many frames the
% dot has been going.  The starting 'life' of each dot will be a random
% number between 0 and dots.lifetime-1 so that they don't all 'die' on the
% same frame:

dots.life =    ceil(rand(1,dots.nDots)*dots.lifetime);

try
%     display = OpenWindow(display);
    win.windowPtrOrScreenNumber = max(Screen('Screens'));
    win.windowPtr = Screen('OpenWindow', win.windowPtrOrScreenNumber, .35);
    for i=1:nFrames
        %convert from degrees to screen pixels
        pixpos.x = angle2pix(display,dots.x)+ display.resolution(1)/2;
        pixpos.y = angle2pix(display,dots.y)+ display.resolution(2)/2;
%         pixpos.x = angle2pix(display.dist,dots.x)+ display.resolution(1)/2;
%         pixpos.y = angle2pix(display.dist,dots.y)+ display.resolution(2)/2;

        Screen('DrawDots',win.windowPtr,[pixpos.x;pixpos.y], dots.size, dots.color,[0,0],1);
        %update the dot position
        dots.x = dots.x + dx;
        dots.y = dots.y + dy;

        %move the dots that are outside the aperture back one aperture
        %width.
        dots.x(dots.x<l) = dots.x(dots.x<l) + dots.apertureSize(1);
        dots.x(dots.x>r) = dots.x(dots.x>r) - dots.apertureSize(1);
        dots.y(dots.y<b) = dots.y(dots.y<b) + dots.apertureSize(2);
        dots.y(dots.y>t) = dots.y(dots.y>t) - dots.apertureSize(2);

        %increment the 'life' of each dot
        dots.life = dots.life+1;

        %find the 'dead' dots
        deadDots = mod(dots.life,dots.lifetime)==0;

        %replace the positions of the dead dots to a random location
        dots.x(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(1) + dots.center(1);
        dots.y(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(2) + dots.center(2);

        Screen('Flip',win.windowPtr);
    end
catch ME
    Screen('CloseAll');
    rethrow(ME)
end
Screen('CloseAll');

%% Circle aperture

try
%     display = OpenWindow(display);
    win.windowPtrOrScreenNumber = max(Screen('Screens'));
    win.windowPtr = Screen('OpenWindow', win.windowPtrOrScreenNumber, .35);
    for i=1:nFrames
        %convert from degrees to screen pixels
        pixpos.x = angle2pix(display,dots.x)+ display.resolution(1)/2;
        pixpos.y = angle2pix(display,dots.y)+ display.resolution(2)/2;
        
        goodDots = (dots.x-dots.center(1)).^2/(dots.apertureSize(1)/2)^2 + ...
        (dots.y-dots.center(2)).^2/(dots.apertureSize(2)/2)^2 < 1;

        Screen('DrawDots',win.windowPtr,[pixpos.x(goodDots);pixpos.y(goodDots)], dots.size, dots.color,[0,0],1);
        %update the dot position
        dots.x = dots.x + dx;
        dots.y = dots.y + dy;

        %move the dots that are outside the aperture back one aperture
        %width.
        dots.x(dots.x<l) = dots.x(dots.x<l) + dots.apertureSize(1);
        dots.x(dots.x>r) = dots.x(dots.x>r) - dots.apertureSize(1);
        dots.y(dots.y<b) = dots.y(dots.y<b) + dots.apertureSize(2);
        dots.y(dots.y>t) = dots.y(dots.y>t) - dots.apertureSize(2);

        %increment the 'life' of each dot
        dots.life = dots.life+1;

        %find the 'dead' dots
        deadDots = mod(dots.life,dots.lifetime)==0;

        %replace the positions of the dead dots to a random location
        dots.x(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(1) + dots.center(1);
        dots.y(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(2) + dots.center(2);

        Screen('Flip',win.windowPtr);
    end
catch ME
    Screen('CloseAll');
    rethrow(ME)
end
Screen('CloseAll');

%% Adding noise

noiseProportion = .4;
noiseAmp = .1;

try
%     display = OpenWindow(display);
    win.windowPtrOrScreenNumber = max(Screen('Screens'));
    win.windowPtr = Screen('OpenWindow', win.windowPtrOrScreenNumber, .35);
    for i=1:nFrames
        %convert from degrees to screen pixels
        pixpos.x = angle2pix(display,dots.x)+ display.resolution(1)/2;
        pixpos.y = angle2pix(display,dots.y)+ display.resolution(2)/2;
        
        goodDots = (dots.x-dots.center(1)).^2/(dots.apertureSize(1)/2)^2 + ...
        (dots.y-dots.center(2)).^2/(dots.apertureSize(2)/2)^2 < 1;
    
        noisyDots = rand(dots.nDots,1) < noiseProportion;
        cohDots = noisyDots == 0;
        
        Screen('DrawDots',win.windowPtr,[pixpos.x(goodDots);pixpos.y(goodDots)], dots.size, dots.color,[0,0],1);
        %update the dot position
        dots.x(cohDots) = dots.x(cohDots) + dx; %+ Noise.*rand(size(dots.x));
        dots.y(cohDots) = dots.y(cohDots) + dy; %+ Noise.*rand(size(dots.y));
        dots.x(noisyDots) = dots.x(noisyDots) + noiseAmp.*rand;
        dots.y(noisyDots) = dots.y(noisyDots) + noiseAmp.*rand;

        %move the dots that are outside the aperture back one aperture
        %width.
        dots.x(dots.x<l) = dots.x(dots.x<l) + dots.apertureSize(1);
        dots.x(dots.x>r) = dots.x(dots.x>r) - dots.apertureSize(1);
        dots.y(dots.y<b) = dots.y(dots.y<b) + dots.apertureSize(2);
        dots.y(dots.y>t) = dots.y(dots.y>t) - dots.apertureSize(2);

        %increment the 'life' of each dot
        dots.life = dots.life+1;

        %find the 'dead' dots
        deadDots = mod(dots.life,dots.lifetime)==0;

        %replace the positions of the dead dots to a random location
        dots.x(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(1) + dots.center(1);
        dots.y(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(2) + dots.center(2);

        Screen('Flip',win.windowPtr);
    end
catch ME
    Screen('CloseAll');
    rethrow(ME)
end
Screen('CloseAll');

%% Final :
clear
close all
% Parameters :
dots.nDots = 500;                % number of dots
dots.color = [255,255,255];      % color of the dots
dots.size = 4;                   % size of dots (pixels)
dots.center = [0,0];           % center of the field of dots (x,y)
dots.apertureSize = [12,12];     % size of rectangular aperture [w,h] in degrees.

dots.speed = 1;       %degrees/second
dots.duration = 5;    %seconds
dots.direction = 0;  %degrees (clockwise from straight up)

dots.lifetime = 120;  %lifetime of each dot (frames)

% First we'll calculate the left, right top and bottom of the aperture (in
% degrees)
l = dots.center(1)-dots.apertureSize(1)/2;
r = dots.center(1)+dots.apertureSize(1)/2;
b = dots.center(2)-dots.apertureSize(2)/2;
t = dots.center(2)+dots.apertureSize(2)/2;
% Each dot will have a integer value 'life' which is how many frames the
% dot has been going.  The starting 'life' of each dot will be a random
% number between 0 and dots.lifetime-1 so that they don't all 'die' on the
% same frame:
dots.life =    ceil(rand(1,dots.nDots)*dots.lifetime);

noiseProportion = .1;
noiseAmp = .1;

display.dist = 57;  %cm
display.width = 30; %cm
tmp = Screen('Resolution',0);
display.resolution = [tmp.width,tmp.height];
secs2frames = @(frameRate, duration) ceil(duration * frameRate);


% Initiatlisation : 
% New random starting positions
dots.x = (rand(1,dots.nDots)-.5)*dots.apertureSize(1) + dots.center(1);
dots.y = (rand(1,dots.nDots)-.5)*dots.apertureSize(2) + dots.center(2);

pixpos.x = [];
pixpos.y = [];



try
%     display = OpenWindow(display);
    win.windowPtrOrScreenNumber = max(Screen('Screens'));
    win.windowPtr = Screen('OpenWindow', win.windowPtrOrScreenNumber, .35);
    display.frameRate = 1/Screen('GetFlipInterval', win.windowPtr);
    nFrames = secs2frames(display.frameRate, dots.duration);
    dx = dots.speed*sin(dots.direction*pi/180)/display.frameRate; 
    dy = -dots.speed*cos(dots.direction*pi/180)/display.frameRate;

    for i=1:nFrames
        %convert from degrees to screen pixels
        pixpos.x = angle2pix(display,dots.x)+ display.resolution(1)/2;
        pixpos.y = angle2pix(display,dots.y)+ display.resolution(2)/2;
        
        goodDots = (dots.x-dots.center(1)).^2/(dots.apertureSize(1)/2)^2 + ...
        (dots.y-dots.center(2)).^2/(dots.apertureSize(2)/2)^2 < 1;
    
        noisyDots = rand(dots.nDots,1) < noiseProportion;
        cohDots = noisyDots == 0;
        
        Screen('DrawDots',win.windowPtr,[pixpos.x(goodDots);pixpos.y(goodDots)], dots.size, dots.color,[0,0],1);
        %update the dot position
        dots.x(cohDots) = dots.x(cohDots) + dx; %+ Noise.*rand(size(dots.x));
        dots.y(cohDots) = dots.y(cohDots) + dy; %+ Noise.*rand(size(dots.y));
        dots.x(noisyDots) = dots.x(noisyDots) + noiseAmp.*rand;
        dots.y(noisyDots) = dots.y(noisyDots) + noiseAmp.*rand;

        %move the dots that are outside the aperture back one aperture
        %width.
        dots.x(dots.x<l) = dots.x(dots.x<l) + dots.apertureSize(1);
        dots.x(dots.x>r) = dots.x(dots.x>r) - dots.apertureSize(1);
        dots.y(dots.y<b) = dots.y(dots.y<b) + dots.apertureSize(2);
        dots.y(dots.y>t) = dots.y(dots.y>t) - dots.apertureSize(2);

        %increment the 'life' of each dot
        dots.life = dots.life+1;

        %find the 'dead' dots
        deadDots = mod(dots.life,dots.lifetime)==0;

        %replace the positions of the dead dots to a random location
        dots.x(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(1) + dots.center(1);
        dots.y(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(2) + dots.center(2);

        Screen('Flip',win.windowPtr);
    end
catch ME
    Screen('CloseAll');
    rethrow(ME)
end
Screen('CloseAll');