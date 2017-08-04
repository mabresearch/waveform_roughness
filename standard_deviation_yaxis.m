function [ stdev ] = standard_deviation_yaxis( waveform )
    waveform(waveform == 0) = [];
    mean_height = mean(waveform);
    [length, ~] = size(waveform); % just in case ocean observation
    stdev = sum((waveform - mean_height) .^ 2) / (length - 1);
    stdev = sqrt(stdev);
end

