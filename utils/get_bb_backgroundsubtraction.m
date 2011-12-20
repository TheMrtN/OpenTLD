function [bb] = get_bb_backgroundsubtraction(bgImage, currentFrame)
%GET_BB_BACKGROUNDSUBSTRACTION   Determines the bounding box.
%   GET_BB_BACKGROUNDSUBSTRACTION(bgImage, currentFrame) determines the
%   bounding box of the object on currentFrame, by substracting the
%   background (bgImage) from it.
%
%   Note that this function might not be very useful when the camera has
%   different positions when shooting the current frame and the background
%   picture.
%
%   The contents of this function used to reside in the
%   determine_initial_bb function.
%
%   Copyright 2011 by Maarten Somhorst.

bb = [];

%% Constants.
% The connectivity used for the command bwlabel. Possible values: 4 or 8.
connectivity = 4;
% The maximum number of gray levels a pixel may differ to be excluded from
% the binary picture. A value of zero includes all pixels from the first
% frame that have a different gray value at the background. A value of one
% allows a pixel to have a gray level +1 or -1, and so on.
diffThresold = 10;
% The minimum fraction of pixels an object must have to be handled as an
% object. Minimum is 0, maximum is 1.
blobSizeThresold = 0.005;
% The minimum distance in pixels between the image border and a blob. If
% the distance is smaller than this value, this function returns with an
% empty bounding box.
minimumBorderDistance = 2;
% Demo flag.
demo = false;

%% Calculate difference between background and first frame
diffGray = abs(bgImage - currentFrame);
% Make it binary.
diffBinary = diffGray > diffThresold;
% If demo=true, show it.
if demo; figure(8); imshow(diffBinary); end;

%% Find the biggest blob.
% Label all connected blobs.
[labeledObjects, numObjects] = bwlabel(diffBinary, connectivity);

% Count the number pixels per blob.
[u, m, n] = unique(labeledObjects);
counts = accumarray(n(:), 1);

% Remove the one that count the background pixels.
background = find(u==0);
u(background) = [];
counts(background) = [];

% If u is empty, then both images were equal.
if isempty(u)
    return;
end;

% Determine the biggest blob and check if it is large enough to be an
% object.
[y,indexes]=max(counts);
[rows,cols] = size(diffBinary);
fractionCovered = y/(rows*cols);
if demo
    disp(['Number of objects found: ' int2str(numObjects) '.']);
    disp(['The biggest object has ' int2str(y) ' pixels (' sprintf('%0.1f', fractionCovered*100) '%) and id ' int2str(u(indexes)) '.']);
end;
if fractionCovered < blobSizeThresold
%     disp(['Warning from ' mfilename ': no object found that covers ' sprintf('%0.1f', blobSizeThresold*100) '% of the first frame or more. ' ]); % returnString
    return
end;

% Make a new image with that single blob and show it.
filteredImage = (labeledObjects==u(indexes))>0;
if demo; figure(9); imshow(filteredImage); end;

% Find the pixels of that single blob.
[i,j] = find(filteredImage>0);

% Determine the corners of the bounding box.
minI = min(i);
maxI = max(i);
minJ = min(j);
maxJ = max(j);

% Check if the blob has a certain distance from the borders.
if minI < minimumBorderDistance || maxI > (rows - minimumBorderDistance) ...
        || minJ < minimumBorderDistance || maxJ > (cols - minimumBorderDistance)
    return;
end

%% Determine the bounding box.
% First we determine some correction variables to correct for shadows.
blobHeight = maxI - minI;
blobWidth = maxJ - minJ;
correctionSides = .1 * blobWidth; % 10% correction for the sides.
correctionTop = .05 * blobHeight; % 5% correction for the top.
correctionBottom = .1 * blobHeight; % 10% correction for the bottom.

% Create the bb vector.
bb = [round(minJ+correctionSides) round(minI+correctionTop) round(maxJ-correctionSides) round(maxI-correctionBottom)]';

end