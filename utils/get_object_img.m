function A = get_object_img(frame,bb)
%GET_OBJECT_IMG   Get the picture inside the bounding box.
%   A = GET_OBJECT_IMG(FRAME,BB) returns the part of the FRAME that is
%   inside the bounding box. BB is a 1x4 vector containing the two
%   coordinates that define the bounding box. These coordinates are allowed
%   to be outside the FRAME. The FRAME is expected to be an MxN matrix.

%   Copyright 2011 by Maarten Somhorst <themrtn@gmail.com>.

global tld;

% If in debug mode, print the coordinates before adjusting them.
if tld.object_debug
    disp('Original bb:');
    bb 
end

% Determine size of frame.
[maxY,maxX] = size(frame);
if tld.object_debug
    disp('Size frame: ');
    disp([maxY maxX]);
end

% Transform to integers.
bb = uint16(bb); 

% Check the X values.
xIndexes = [1 3];
xs = bb(xIndexes);
for i=1:length(xs)
    x = xs(i);
    if x < 1
        bb(xIndexes(i)) = 1;
    elseif x > maxX
        bb(xIndexes(i)) = maxX;
    end
end

% Check the Y values.
yIndexes = [2 4];
ys = bb(yIndexes);
for i = 1:length(ys)
    y = ys(i);
    if y < 1
        bb(yIndexes(i)) = 1;
    elseif y > maxY
        bb(yIndexes(i)) = maxY;
    end
end

% If in debug mode, print the adjusted coordinates.
if tld.object_debug
    disp('Adjusted bb:');
    bb
end

A = frame(bb(2):bb(4),bb(1):bb(3));

end