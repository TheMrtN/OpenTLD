function [bgImage] = get_background_image(input)
%GET_BACKGROUND_IMAGE  Returns the background image.
%   This function returns the background image in the input folder, which
%   is expected in a folder called 'background'.
%
%   Copyright 2011 by Maarten Somhorst.

bgImage = [];

%% Constants.
% The string where each error ends with if it exits this function.
returnString = 'Unable to get background image.';

%% Check if there's a background folder.
bgDir = [input 'background/'];
if(~exist(bgDir,'dir'))
    disp(['Error in ' mfilename ': the folder ' bgDir ' does not exist. ' returnString]);
    return
end;

%% Check if there's exactly one picture in the background folder.
bgFile = img_dir(bgDir);
numBgFiles = length(bgFile);
if(numBgFiles == 0)
    disp(['Error in ' mfilename ': there are no images in the folder ' bgDir '. Please provide one image of the background. ' returnString]);
    return
elseif(numBgFiles > 1)
    disp(['Warning from ' mfilename ': the folder ' bgDir ' contains ' int2str(numBgFiles) ' pictures. The first one is used.']);
end;

%% Read the background picture and convert to grayscale if needed.
bgImage = imread(bgFile(1).name);
if(ndims(bgImage)==3)
    bgImage = rgb2gray(bgImage);
end;

end

