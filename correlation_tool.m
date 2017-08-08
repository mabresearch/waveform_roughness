% Gets GLAH01 and GLAH14 data from folders specified in GLAH01Dir and
% GLAH14Dir. Finds similar i_rec_ndx values to correlate waveforms with
% respective GLAH14 processed data.
% Author: Max A Bowman
% Version: 8/08/2017
tic
% Get data files in data directory
GLAH01Dir = '../data/01';
GLAH14Dir = '../data/14';
GLAH01Files = dir([GLAH01Dir filesep '*.H5']);
GLAH14Files = dir([GLAH14Dir filesep '*.H5']);

% Keep track of begin and end times of GLAH14 files
GLAH14Begin = [];
GLAH14End = [];

% Stores indexes to compare via intersect
GLAH01rec = [];
GLAH14rec = [];

% GLAH14 and GLAH01 data properties
h5lat = [];
h5lon = [];
h5elev = [];
h5saturation = [];
h5gain = [];

waveforms = [];

num14files = 0;

% Loop through files, populate data
for file = GLAH14Files'
    times = h5read([GLAH14Dir filesep file.name], '/Data_40HZ/DS_UTCTime_40');
    rec = h5read([GLAH14Dir filesep file.name], '/Data_40HZ/Time/i_rec_ndx');
    GLAH14Begin = cat(1, GLAH14Begin, times(1));
    GLAH14End   = cat(1, GLAH14End, times(end));
    GLAH14rec = cat(1, GLAH14rec, rec);
    
    h5lat = cat(1, h5lat, h5read([GLAH14Dir filesep file.name], '/Data_40HZ/Geolocation/d_lat'));
    h5lon = cat(1, h5lon, h5read([GLAH14Dir filesep file.name], '/Data_40HZ/Geolocation/d_lon'));
    h5elev = cat(1, h5elev, h5read([GLAH14Dir filesep file.name], '/Data_40HZ/Elevation_Surfaces/d_elev'));
    h5saturation = cat(1, h5saturation, h5read([GLAH14Dir filesep file.name], '/Data_40HZ/Quality/sat_corr_flg'));
    h5gain = cat(1, h5gain, h5read([GLAH14Dir filesep file.name], '/Data_40HZ/Waveform/i_gval_rcv'));
    
    num14files = num14files + 1;
end

for file = GLAH01Files'
    times = h5read([GLAH01Dir filesep file.name], '/Data_40HZ/DS_UTCTime_40');
    for index = 1:num14files
        if times(end) > GLAH14Begin(index) && times(1) < GLAH14End(index)
            rec = h5read([GLAH01Dir filesep file.name], '/Data_40HZ/Time/i_rec_ndx');
            GLAH01rec = cat(1, GLAH01rec, rec);
            waveforms = cat(1, waveforms, h5read([GLAH01Dir filesep file.name], '/Data_40HZ/Waveform/RecWaveform/r_rng_wf')); 
        end
    end
end

% Filter out GLAH14 data with bad lon, lat, gain, or saturation
valid = h5lon <= 360 & h5lat <= 90 & h5gain < 250 & h5saturation < 2;

[den, ~] = size(valid);
[num, ~] = size(find(valid));
disp(100 - num / den * 100);

h5lat = h5lat(valid);
h5lon = h5lon(valid);
h5elev = h5elev(valid);
h5saturation = h5saturation(valid);
h5gain = h5gain(valid);
GLAH14rec = GLAH14rec(valid);

% Change longitude range to [-180, 180]
h5lon = h5lon - 180;

% Get common 1HZ indices
common = intersect(GLAH01rec, GLAH14rec);

% Now, correlate a couple of waveforms!!!
% Pick a random index from common indices.
% glah14second and glah01second now have one
% second of ICESat data in associative arrays.
glah14second = find(GLAH14rec == common(200));
glah01second = find(GLAH01rec == common(200));

toc
% Graph a second of ICESat waveforms
for index = 1:40
    wv = waveforms(1:544, glah01second(index));
    wv(wv < 0.05 * max(wv)) = 0;

    plot(1:544, wv);
    title([h5lat(glah14second(index)) h5lon(glah14second(index))]);
    xlabel('Time (ns)');
    ylabel('Energy (volts)');
    pause(0.5);
end