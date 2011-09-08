% Copyright 2011 Zdekek Kalal
% File created by Maarten Somhorst.
%
% This file is not part of the original TLD. However, all lines are
% copied from tldExample.
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
% tldExampleLoop(tld, finish) is the loop through the movie sequence that
% used to be part of tldExample. In order to allow other functions to use
% this loop without duplicated code, this function is created.
function [tld] = tldExampleLoop(tld)

set(2,'KeyPressFcn', @handleKey); % open figure for display of results
finish = 0; 
function handleKey(dummy1,dummy2), finish = 1; fprintf('Execution interrupted by keypress.\n'); end % by pressing any key, the process will exit

for i = 2:length(tld.source.idx) % for every frame
    
    tld = tldProcessFrame(tld,i); % process frame i
    tldDisplay(1,tld,i); % display results on frame i
    
    if finish % finish if any key was pressed
        if tld.source.camera
            stoppreview(tld.source.vid);
            closepreview(tld.source.vid);
            close(1);
        end
        close(2);
        return;
    end
    
    if tld.plot.save
        img = getframe;
        imwrite(img.cdata,[tld.output num2str(i,'%05d') '.png']);
    end
    
    % Save a picture of the object each frame.
    if isfield(tld.plot,'save_object') && tld.plot.save_object && isfield(tld,'object')
        % Determine the bounding box.
        currentBB = tld.bb(:,tld.source.idx(i)); % Watch out: this vector can contain negative values or NaNs.

        % If none of the numbers is a NaN, save the object picture.
        if sum(isnan(currentBB)) == 0
            % Get the frame.
            frame = tld.img{i}.input;
            % Determine the part of the frame that is the object.
            object = get_object_img(frame,currentBB);
            % Save the object picture.
            imwrite(object,[tld.object 'object' num2str(i,'%05d') '.png'],'PNG');
        end
    end

end

end