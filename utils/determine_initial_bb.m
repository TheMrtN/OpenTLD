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
%   so that TLD can use it. For this substraction process, the function
%   get_bb_backgroundsubstraction() is used.
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
% The string where each error ends with if it exits this function.
returnString = 'Unable to determine bounding box.';

%% Load pictures.
% Get background picture.
bgPic = get_background_image(input);

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

%% Get bounding box.
coordsVector = get_bb_backgroundsubtraction(bgPic, firstFrame);

%% Check the size of the bounding box and save it when OK.
if isempty(coordsVector)
    disp(['Warning from ' mfilename ': the size of the object is smaller than the threshold. ' returnString]);
    return;
elseif min(bb_size(coordsVector)) < min_win
    % If the bounding box is too big, we print a warning and return.
    disp(['Warning from ' mfilename ': the size of the determined bounding box is not large enough for TLD. ' returnString]);
    return;
end;
dlmwrite([input 'init.txt'], coordsVector');

end