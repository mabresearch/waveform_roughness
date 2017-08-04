function [ width ] = waveform_width( waveform )
    % Calculates the width of a waveform from the index of the first rising
    % edge to the index of the last falling edge
    g = find(waveform > 0);
    width = g(end) - g(1);
end

