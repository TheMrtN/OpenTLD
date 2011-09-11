% Copyright 2011 Zdekek Kalal
% File created by Maarten Somhorst.
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
% tldExample2(opt, startIndex, bb, handle) works a lot like tldExample(opt),
% but is able to start at the frame determined by the startIndex parameter.
% Furthermore, an existing handle can be given as a parameter.

function [bb, conf] = tldExample2(opt, startIndex, initialBB, handle)

% Check index.
if startIndex <= 0
    disp(['Warning in ' mfilename ': start index cannot be smaller than or equal to zero. An index of one is assumed.']);
    startIndex = 1;
end;
% Check initialBB.
if size(initialBB,1) ~= 4
    disp(['Error in ' mfilename ': intial bounding box has a unusual size. Cannot initialize TLD.']);
    bb = []; conf = [];
    return;
end;

global tld; % holds results and temporal variables

% If a valid handle is given, save it.
if handle ~= -1
    tld.handle = handle;
end;

% INITIALIZATION ----------------------------------------------------------

% From: tldInitSource
opt.source.files = img_dir(opt.source.input);
opt.source.files = opt.source.files(startIndex:end); % Filter the relevant frames.
opt.source.idx   = 1:length(opt.source.files);
% -------------------

figure(2);

% From: tldInitFirstFrame
opt.source.im0  = img_get(opt.source, opt.source.idx(1));
opt.source.bb = initialBB;
% -----------------------

tld = tldInit(opt,tld); % train initial detector and initialize the 'tld' structure
tld = tldDisplay(0,tld); % initialize display

% RUN-TIME ----------------------------------------------------------------

tld = tldExampleLoop(tld);

% RETURN RESULTS ----------------------------------------------------------

bb = tld.bb; conf = tld.conf;

end