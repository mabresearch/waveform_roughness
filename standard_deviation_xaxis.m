function [ stdev ] = standard_deviation_xaxis( waveform )
    bins = find(waveform > 0);
    [length, ~] = size(bins);
    m = mean(bins);
    stdev = sqrt(sum((bins - m) .* (bins - m)) / (length - 1));

end

