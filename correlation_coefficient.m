function [ r ] = correlation_coefficient(x, y)
    % Normalize 
    x = x / max(x);
    y = y / max(y);
    % Calculate
    y = y - mean(y);
    x = x - mean(x);
    numerator = sum(x .* y);
    denominator = sqrt(sum(x .* x)) * sqrt(sum(y .* y));
    r = numerator / denominator;
end