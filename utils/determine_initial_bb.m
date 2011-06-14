function determine_initial_bb(input, min_win)
%DETERMINE_INITIAL_BB   Determines the bounding box of the first frame.
%   DETERMINE_INITIAL_BB('input_directory') determines the bounding box for
%   the dataset in the folder 'input_directory' and writes it to a file
%   called init.txt.
%
%   A picture of the background is required to exist in the folder
%   'input_directory/background/'. This function substracts the background
%   from the first frame in order to find the largest blob in the picture.
%   The bounding box coordinates are written to 'input_directory/init.txt'
%   so that TLD can use it.
%
%   When the bounding box of the object is determined, this function checks
%   if the size (minimum of width and height) is smaller than min_win. If
%   so, this function returns and the file is not written to disk.
%
%   Note that this function might not be very useful when the camera has
%   different positions when shooting the first frame and the background
%   picture.
%
%   Copyright 2011 by Maarten Somhorst.

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
blobSizeThresold = 0.0;
% The string where each error ends with if it exits this function.
returnString = 'Unable to determine bounding box.';
% Demo flag.
demo = false;

%% Load pics
% Check if there's a background picture.
bgDir = [input 'background/'];
if(~exist(bgDir,'dir'))
    disp(['Error in ' mfilename ': the folder ' bgDir ' does not exist. ' returnString]);
    return
end;
bgFile = img_dir(bgDir);
numBgFiles = length(bgFile);
if(numBgFiles == 0)
    disp(['Error in ' mfilename ': there are no images in the folder ' bgDir '. Please provide one image of the background. ' returnString]);
    return
elseif(numBgFiles > 1)
    disp(['Warning from ' mfilename ': the folder ' bgDir ' contains ' int2str(numBgFiles) ' pictures. The first one is used.']);
end;
% Load the background picture.
bgPic = imread(bgFile(1).name);
if(ndims(bgPic)==3)
    bgPic = rgb2gray(bgPic);
end;

% Check if there is data.
dataFiles = img_dir(input);
if(isempty(dataFiles))
    disp(['Error in ' mfilename ': there are no pictures in the folder ' input '. ' returnString]);
    return
end;
% Load the first frame.
firstFrame = imread(dataFiles(1).name);
if(ndims(firstFrame)==3)
    firstFrame = rgb2gray(firstFrame);
end;

%% Calculate difference between background and first frame
diffGray = abs(bgPic - firstFrame);
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
    disp(['Warning from ' mfilename ': no object found that covers ' sprintf('%0.1f', blobSizeThresold*100) '% of the first frame or more. ' returnString]);
    return
end;

% Make a new image with that single blob and show it.
filteredImage = (labeledObjects==u(indexes))>0;
if demo; figure(9); imshow(filteredImage); end;

% Find the pixels of that single blob.
[i,j] = find(filteredImage>0);

%% Determine the bounding box and write it to init.txt.
% First we determine some correction variables to correct for shadows.
minI = min(i);
maxI = max(i);
blobHeight = maxI - minI;
minJ = min(j);
maxJ = max(j);
blobWidth = maxJ - minJ;
correctionSides = .1 * blobWidth; % 10% correction for the sides.
correctionTop = .05 * blobHeight; % 5% correction for the top.
correctionBottom = .1 * blobHeight; % 10% correction for the bottom.

% Create the vector, check it and write it to init.txt.
coordsVector = [round(minJ+correctionSides) round(minI+correctionTop) round(maxJ-correctionSides) round(maxI-correctionBottom)];
if min(bb_size(coordsVector')) < min_win
    % If the bounding box is too big, we print a warning and return.
    disp(['Warning from ' mfilename ': the size of the determined bounding box is not large enough for TLD. ' returnString]);
    return
end;
dlmwrite([input 'init.txt'], coordsVector);

end