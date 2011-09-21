% Copyright 2011 Zdenek Kalal
%
% This file is part of TLD.
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

addpath(genpath('.')); init_workspace; 

% Debugging flags
opt.print_debug     = 0; % print debug info to console
opt.savegroundtruth = 0; % save ground truth data to files
opt.object_debug    = 0; % print debug messages from get_object_img

% Feature flags
remember_fps        = 0; % toggle remembering the fps in a global vector called 'fps'
save_object         = 0; % toggle saving the picture inside the bounding box of every frame
detect_object       = 1; % toggle detecting if an object appears in the scene

% Input / output settings
% input               = '_input/'; % motorbike example
input               = '_input_entrance/'; % entrance example with a car driving into the entrance
opt.source          = struct('camera',0,'input',input,'bb0',[]); % camera/directory swith, directory_name, initial_bounding_box (if empty, it will be selected by the user)
opt.output          = '_output/'; mkdir(opt.output); % output directory that will contain bounding boxes + confidence
if save_object
    opt.object      = '_object/'; mkdir(opt.object); delete([opt.object '*.png']); % output directory that will contain the images inside the bounding box of every frame
end

% Other settings
min_win             = 24; % minimal size of the object's bounding box in the scanning grid, it may significantly influence speed of TLD, set it to minimal size of the object
patchsize           = [15 15]; % size of normalized patch in the object detector, larger sizes increase discriminability, must be square
fliplr              = 0; % if set to one, the model automatically learns mirrored versions of the object
maxbbox             = 1; % fraction of evaluated bounding boxes in every frame, maxbox = 0 means detector is truned off, if you don't care about speed set it to 1
update_detector     = 1; % online learning on/off, of 0 detector is trained only in the first frame and then remains fixed
opt.plot            = struct('pex',1,'nex',1,'dt',1,'confidence',1,'target',1,'replace',0,'drawoutput',3,'draw',0,'pts',1,'help', 0,'patch_rescale',1,'save',0,'save_object',save_object); 

% If we don't wait for the object to appear, we don't use camera input, the
% init.txt does not exist and there is a background directory, determine
% the bounding box of the input by making a init.txt with the bounding box
% of the biggest blob in the first frame.
% This requires a picture of the background in the folder [opt.source.input
% 'background/'].
if ~detect_object && ~opt.source.camera && ~exist([opt.source.input 'init.txt'], 'file') && exist([opt.source.input 'background/'], 'dir')
    determine_initial_bb(opt.source.input, min_win);
end; % else, the bounding box is determined by the user or the existing init.txt is used.

% Do-not-change -----------------------------------------------------------

opt.model           = struct('min_win',min_win,'patchsize',patchsize,'fliplr',fliplr,'ncc_thesame',0.95,'valid',0.5,'num_trees',10,'num_features',13,'thr_fern',0.5,'thr_nn',0.65,'thr_nn_valid',0.7);
opt.p_par_init      = struct('num_closest',10,'num_warps',20,'noise',5,'angle',20,'shift',0.02,'scale',0.02); % synthesis of positive examples during initialization
opt.p_par_update    = struct('num_closest',10,'num_warps',10,'noise',5,'angle',10,'shift',0.02,'scale',0.02); % synthesis of positive examples during update
opt.n_par           = struct('overlap',0.2,'num_patches',100); % negative examples initialization/update
opt.tracker         = struct('occlusion',10);
opt.control         = struct('maxbbox',maxbbox,'update_detector',update_detector,'drop_img',1,'repeat',1,'remember_fps',remember_fps);

        
% Run TLD -----------------------------------------------------------------
if remember_fps
    % Create empty FPS vector.
    global fps;
    fps = [];
end;

% If detect_object is disabled, run TLD as usual.
bb = []; conf = [];
if ~detect_object
    %profile on;
    [bb,conf] = tldExample(opt);
    %profile off;
    %profile viewer;
else % If detect_object is enabled.
    % Play the frame sequence until an object of sufficient size is
    % detected.
    [i, initialBB] = tldWaitForObject(opt);
    % If it returned a valid index and bounding box, run TLD.
    if i ~= -1 && ~isempty(initialBB)
        % Save the handle, but clear the rest of the tld variable.
        global tld;
        handle = -1;
        if isfield(tld,'handle')
            handle = tld.handle;
        end;
        clear global tld;
        
        % Run TLD.
        [bb, conf] = tldExample2(opt, i, initialBB, handle);
    elseif i == 1 && isempty(initialBB) % Something went wrong during initialization.
        % Run TLD as usual.
        disp(['Notification from ' mfilename ': intialization of automatically detecting an object failed. Starting TLD as usual.']);
        [bb,conf] = tldExample(opt);
    else
        disp(['Notification from ' mfilename ': waited for an object to appear, but reached the end of the frame sequence before we could find one.']);
    end;
end;

% Save results ------------------------------------------------------------
dlmwrite([opt.output '/tld.txt'],[bb; conf]');
disp(['Results saved to ./' opt.output '.']);
