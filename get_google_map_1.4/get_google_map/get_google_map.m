function [XX YY M Mcolor] = get_google_map(lat, lon, varargin)


%    % Get the map
%    [XX YY M Mcolor] = get_google_map(43.0738740,-70.713993);
%    % Plot the result
%    imagesc(XX,YY,M); shading flat;
%    colormap(Mcolor)

persistent apiKey
if isnumeric(apiKey)
    % first run, check if API key file exists
    if exist('api_key.mat','file')
        load api_key
    else
        apiKey = 'AIzaSyDp0MMBny3hSBDgI7aWjBtz1qYZ-_YPwM8';
    end
end

cal_distance = 30;  % in degrees of latitude
degpermeter = 1/60*1/1852;

% HANDLE ARGUMENTS
height = 640;
width = 640;
zoomlevel = 10;
maptype = 'satellite';

markeridx = 1;
markerlist = {};
if nargin > 2
    for idx = 1:2:length(varargin)
        switch varargin{idx}
            case 'Height'
                height = varargin{idx+1};
            case 'Width'
                width = varargin{idx+1};
            case 'Zoom'
                zoomlevel = varargin{idx+1};
            case 'MapType'
                maptype = varargin{idx+1};
            case 'Marker'
                markerlist{markeridx} = varargin{idx+1};
                markeridx = markeridx + 1;
            case 'apikey'
                apiKey = varargin{idx+1}; % set new key
                % save key to file
                funcFile = which('get_google_map.m');
                pth = fileparts(funcFile);
                keyFile = fullfile(pth,'api_key.mat');
                save(keyFile,'apiKey')
            otherwise
                error(['Unrecognized variable: ' varargin{idx}])
        end
    end
end


if zoomlevel <1 || zoomlevel > 19
    error('Zoom Level must be > 0 and < 20.')
end

if mod(zoomlevel,1) ~= 0
    zoomlevel = round(zoomlevel)
    warning(['Zoom Level must be an integer. Rounding to '...
        num2str(zoomlevel)]);
end

% CONSTRUCT QUERY URL
preamble = 'http://maps.googleapis.com/maps/api/staticmap';
location = ['?center=' num2str(lat,10) ',' num2str(lon,10)];
cal_location = ['?center=' num2str(lat - degpermeter*cal_distance,10) ',' num2str(lon,10)];

zoom = ['&zoom=' num2str(zoomlevel)];
size = ['&size=' num2str(width) 'x' num2str(height)];
maptype = ['&maptype=' maptype ];
markers = '&markers=';
for idx = 1:length(markerlist)
    if idx < length(markerlist)
            markers = [markers markerlist{idx} '%7C'];
    else
            markers = [markers markerlist{idx}];
    end
end
format = '&format=png';
if ~isempty(apiKey)
    key = ['&key=' apiKey];
else
    key = '';
end
sensor = '&sensor=false';
url = [preamble location zoom size maptype format markers sensor key];
cal_url = [preamble cal_location zoom size maptype format markers sensor key];

% GET THE IMAGE
[M Mcolor] = webread(url);
M = cast(M,'double');

% ESTIMATE BOUNDS OF IMAGE:
% We get 2 images instead of just one, separated by a known distance. Then
% we cross-correlate one with the other to find the distance between the
% two images in pixels. Divide one by the other and you have distance per
% pixel. From this and the center point of we can calculate the coordinates
% of each. 

% GET THE CAL IMAGE
[Mcal Mcolorcal] = webread(cal_url);
Mcal = cast(Mcal,'double');

% Cross correlate a column in the middle of the data to get the shift
% between them in pixels.
comparecol = floor(width/2);
c = xcorr(M(20:end,comparecol),Mcal(20:end,comparecol)); % skip first 20 pixels
c = fftshift(c);
[val, pixels] = max(c(1:floor(end/2)));

dx = cal_distance/pixels;

% Convert coordinates to UTM.
[lonutm, latutm, zone] = deg2utm(lat,lon);
L = dx*(width-1);
W = dx*(height-1);
XX = 0:dx:L;
YY = 0:dx:W;
XX = XX - mean(XX) + lonutm;
YY = YY - mean(YY) + latutm;


