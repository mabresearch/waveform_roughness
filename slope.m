function [ slope ] = slope( el, lat, long, first, last )
    slope = [];
    for index = first:last
        dlong = long(index + 1) - long(index - 1);
        dlat = lat(index + 1) - lat(index - 1);
        dy = el(index + 1) - el(index - 1);
        
        a = (sind(dlat / 2))^2 + cosd(lat(index - 1)) * cosd(lat(index + 1)) * (sind(dlong / 2))^2;
        c = 2 * atan2(sqrt(a), sqrt(1-a));
        dx = 6371e3 * c; % in meters
        
        slope = cat(1, slope, dy / dx);
    end
end