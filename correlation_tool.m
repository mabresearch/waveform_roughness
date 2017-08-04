% Gets GLAH01 and GLAH14 data from folders specified in GLAH01Dir and
% GLAH14Dir. Finds similar i_rec_ndx values to correlate waveforms with
% respective GLAH14 processed data.
% Author: Max A Bowman
% Version: 8/02/2017
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

h5lon(h5lon > 360) = 0;
h5lon = h5lon - 180;
h5lat(h5lat > 90) = 0;

common = intersect(GLAH01rec, GLAH14rec);

% Now, correlate a couple of waveforms!!!
glah14second = find(GLAH14rec == common(300));
glah01second = find(GLAH01rec == common(300));

c = 25;

disp([h5lat(glah14second(c)) h5lon(glah14second(c))]);

wv = waveforms(1:544, glah01second(c));
wv(wv < 0.05 * max(wv)) = 0;
plot(1:544, wv);
title('Waveform');
xlabel('Time (ns)');
ylabel('Energy (volts)');

disp(standard_deviation_yaxis(wv));
disp(standard_deviation_xaxis(wv));
disp(waveform_width(wv));
disp(max(wv));
disp(h5gain(glah14second(c)));

s = slope(h5elev, h5lat, h5lon, 10000, 20000);

toc