% Copyright 2011 Zdekek Kalal
% File created by Maarten Somhorst
%
% This file is not part of the original TLD. However, most of the lines are
% copied from tldExample or other functions (mentioned in the comments).
% 
% TLD is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% TLD is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with TLD.  If not, see <http://www.gnu.org/licenses/>.
%
% tldWaitForObject(opt) processes and displays each frame until an object
% is detect. Then it returns the frame index and the bounding box.
%
% If no object is found and the last frame is processed, an index of -1 and
% an empty bounding box is returned. If something went wrong with the
% background image, the index is set to 1 and an empty bounding box is
% returned.

function [index, bb] = tldWaitForObject(opt)

% INITIALIZATION ----------------------------------------------------------
index = -1;
bb = [];

global tld;
opt.source = tldInitSource(opt.source);

figure(2); set(2,'KeyPressFcn', @handleKey); % open figure for display of results
finish = 0; 
function handleKey(dummy1,dummy2), finish = 1; fprintf('Execution interrupted by keypress.\n'); end % by pressing any key, the process will exit

% From: tldInitFirstFrame
opt.source.im0  = img_get(opt.source,opt.source.idx(1));
% -----------------------

% From: tldInit
if ~isempty(tld);
    handle = tld.handle;
    tld = opt;
    tld.handle = handle;
else
    tld = opt;
end

tld.img     = cell(1,length(tld.source.idx));
tld.img{1}  = tld.source.im0;
% -------------

% Load background picture.
bg = get_background_image(tld.source.input);
if isempty(bg)
    disp(['Error in ' mfilename ': no background image found. Returning.']);
    index = 1;
    return;
end;

% Check if the first frame already contains the object. If so, return.
bb = get_bb_backgroundsubtraction(bg, tld.img{1}.input);
if ~isempty(bb) && min(bb_size(bb)) >= tld.model.min_win
    index = 1;
    return;
end;

% From: tldDisplay
tld.handle = imshow(tld.img{1}.input,'initialmagnification','fit');
set(gcf,'MenuBar','none','ToolBar','none','color',[0 0 0]);
set(gca,'position',[0 0 1 1]);
set(tld.handle,'cdata',tld.img{1}.input);
hold on;
set(gcf,'Position',[100 100 [640 360]]);
% ----------------


% RUN-TIME ----------------------------------------------------------------

for i = 2:length(tld.source.idx) % for every frame

    % From: tldProcessFrame    
    tld.img{i} = img_get(tld.source,i); % grab frame
    % ---------------------

    % Check if this frame contains an object. If so, return.
    bb = get_bb_backgroundsubtraction(bg, tld.img{i}.input);
    if ~isempty(bb) && min(bb_size(bb)) >= tld.model.min_win
        index = i;
        return;
    end;

    % From: tldDisplay
    h = get(gca,'Children'); delete(h(1:end-1));
    img = tld.img{i}.input; % draw image
    set(tld.handle,'cdata',img); hold on;
    drawnow;
    tic;
    % ----------------
    
    if finish % finish if any key was pressed
        if tld.source.camera
            stoppreview(tld.source.vid);
            closepreview(tld.source.vid);
             close(1);
        end
        close(2);
        return;
    end
    
    if tld.plot.save == 1
        img = getframe;
        imwrite(img.cdata,[tld.output num2str(i,'%05d') '.png']);
    end
    
end

end

