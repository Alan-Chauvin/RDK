% Proto_RDK
% by Kevin Parisot - 

clear
close all
% Parameters :
dots.nDots = 1000;                % number of dots
dots.color = [255,255,255]./2;      % color of the dots
dots.size = 1;                   % size of dots (pixels)
dots.center = [0,0];           % center of the field of dots (x,y)
dots.apertureSize = [2, 2]; %[1.5,1.5];     % size of rectangular aperture [w,h] in degrees.

dots.speed = 1;       %degrees/second
dots.duration = 5;    %seconds
dots.direction = 0;  %degrees (clockwise from straight up)

dots.lifetime = 50000;  %lifetime of each dot (seconds)

% First we'll calculate the left, right top and bottom of the aperture (in
% degrees)
l = dots.center(1)-dots.apertureSize(1)/2;
r = dots.center(1)+dots.apertureSize(1)/2;
b = dots.center(2)-dots.apertureSize(2)/2;
t = dots.center(2)+dots.apertureSize(2)/2;

% ======= NOISE PARAMETER ========
noiseType = 'direction2'; % eihter : direction, walk, position
noiseProportion = .95;
noiseAmp = 1; %.05;
% ================================

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
%     Screen('Preference', 'SkipSyncTests', 1);
    win.windowPtrOrScreenNumber = max(Screen('Screens'));
    win.windowPtr = Screen('OpenWindow', win.windowPtrOrScreenNumber, .35);
    display.frameRate = 1/Screen('GetFlipInterval', win.windowPtr);
    
%     display.resolution = [1280 1024];
    nFrames = secs2frames(display.frameRate, dots.duration);
    dx_const = dots.speed*sin(dots.direction*pi/180)/display.frameRate; 
    dy_const = -dots.speed*cos(dots.direction*pi/180)/display.frameRate;
    [dth, dr] = cart2pol(dx_const, dy_const);
    dots.dir = dth .* ones(1,dots.nDots);
    if strcmp(noiseType, 'direction2')
        noisyDots = rand(dots.nDots,1) < noiseProportion;
        noisyDots = sort(noisyDots);
        cohDots = noisyDots == 0;
        
        newDotsNoisy = logical(noisyDots');
        noise = -pi + (pi + pi) .* rand(1,dots.nDots);
        if not(isempty(dots.dir(newDotsNoisy)))
            dots.dir(newDotsNoisy) = noise(newDotsNoisy);
        end
        
        newDotsCoh = logical(cohDots');
        if not(isempty(dots.dir(newDotsCoh)))
            temp = dth .* ones(size(dots.dir));
            dots.dir(newDotsCoh) = temp(newDotsCoh);
        end
    end
    % Each dot will have a integer value 'life' which is how many frames the
    % dot has been going.  The starting 'life' of each dot will be a random
    % number between 0 and dots.lifetime-1 so that they don't all 'die' on the
    % same frame:
    dots.lifetimeframes = secs2frames(display.frameRate, dots.lifetime);
    dots.life =    ceil(rand(1,dots.nDots)*dots.lifetimeframes);

    for i=1:nFrames
        %convert from degrees to screen pixels
        pixpos.x = angle2pix(display,dots.x)+ display.resolution(1)/2;
        pixpos.y = angle2pix(display,dots.y)+ display.resolution(2)/2;
        
        goodDots = (dots.x-dots.center(1)).^2/(dots.apertureSize(1)/2)^2 + ...
        (dots.y-dots.center(2)).^2/(dots.apertureSize(2)/2)^2 < 1;
    
    if not(strcmp(noiseType, 'direction2'))
        noisyDots = rand(dots.nDots,1) < noiseProportion;
        cohDots = noisyDots == 0;        
    end
        
        Screen('DrawDots',win.windowPtr,[pixpos.x(goodDots);pixpos.y(goodDots)], dots.size, dots.color,[0,0],1);
        
        %update the dot position
        dots.x(cohDots) = dots.x(cohDots) + dx_const; %+ Noise.*rand(size(dots.x));
        dots.y(cohDots) = dots.y(cohDots) + dy_const; %+ Noise.*rand(size(dots.y));
        [dots.th, dots.r] = cart2pol(dots.x, dots.y);
        switch noiseType
            case 'walk'
                noise = noiseAmp.*randn(size([dots.x; dots.y]));
                dots.x(noisyDots) = dots.x(noisyDots) + noise(1, noisyDots); % noiseAmp.*randn;
                dots.y(noisyDots) = dots.y(noisyDots) + noise(2, noisyDots); % noiseAmp.*randn;
            case 'direction'
                noise = -pi + (pi + pi) .* rand(1,dots.nDots);
                [dx_temp, dy_temp] = pol2cart(noise, dr);
                dots.x(noisyDots) = dots.x(noisyDots) + dx_temp(noisyDots);
                dots.y(noisyDots) = dots.y(noisyDots) + dy_temp(noisyDots);
            case 'position'
                dots.x(noisyDots) = (rand(1,sum(noisyDots))-.5)*dots.apertureSize(1) + dots.center(1);
                dots.y(noisyDots) = (rand(1,sum(noisyDots))-.5)*dots.apertureSize(2) + dots.center(2);
            case 'direction2'                
                [dx_temp, dy_temp] = pol2cart(dots.dir, dr);
                dots.x(noisyDots) = dots.x(noisyDots) + dx_temp(noisyDots);
                dots.y(noisyDots) = dots.y(noisyDots) + dy_temp(noisyDots); 
        end

        %move the dots that are outside the aperture back one aperture
        %width.
        dots.x(dots.x<l) = dots.x(dots.x<l) + dots.apertureSize(1);
        dots.x(dots.x>r) = dots.x(dots.x>r) - dots.apertureSize(1);
        dots.y(dots.y<b) = dots.y(dots.y<b) + dots.apertureSize(2);
        dots.y(dots.y>t) = dots.y(dots.y>t) - dots.apertureSize(2);

        %increment the 'life' of each dot
        dots.life = dots.life+1;

        %find the 'dead' dots
        deadDots = mod(dots.life,dots.lifetimeframes)==0;

        %replace the positions of the dead dots to a random location
        dots.x(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(1) + dots.center(1);
        dots.y(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(2) + dots.center(2);
        if strcmp(noiseType, 'direction2')
            newDotsNoisy = logical(noisyDots' .* deadDots);
            noise = -pi + (pi + pi) .* rand(1,dots.nDots);
            if not(isempty(dots.dir(newDotsNoisy)))
                dots.dir(newDotsNoisy) = noise(newDotsNoisy);
            end
            
            newDotsCoh = logical(cohDots' .* deadDots);
            if not(isempty(dots.dir(newDotsCoh)))
                temp = dth .* ones(size(dots.dir));
                dots.dir(newDotsCoh) = temp(newDotsCoh); 
            end
        end

        Screen('Flip',win.windowPtr);
    end
catch ME
    Screen('CloseAll');
    rethrow(ME)
end
Screen('CloseAll');