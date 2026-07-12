clc
clear
close all

%% Parameters
M = 4;                 
d = 4;              
freq = 3e8;           
lambda = physconst('LightSpeed')/freq;

%% Dipole Array
element = phased.IsotropicAntennaElement;
ra = phased.URA('Size', [M M], 'ElementSpacing', [d*lambda d*lambda], 'Element', element);

figure;
viewArray(ra);

%% Azimuth
figure;
pattern(ra, freq, -180:180, 0, 'CoordinateSystem', 'polar');
title('\theta = 90^\circ (Azimuth)')

%% Elevation (φ=0)
figure;
pattern(ra, freq, 0, -90:90, 'CoordinateSystem', 'polar');
title('\phi = 0 (Elevation)')

%% Directivity
D = pattern(ra, freq, 90, 0);
fprintf('Directivity (at θ = 90°, φ = 0°): %.2f dBi\n', D);
