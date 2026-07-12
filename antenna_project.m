clc; clear; close all;

%% ===== Parameters =====
lambda = 1;                % Wavelength [m]
f = 3e8/lambda;            % Frequency [Hz]
k = 2*pi/lambda;           % Wavenumber
L = lambda/2;              % Dipole length
a = 0.001*lambda;          % Wire radius
eta0 = 120*pi;             % Free space impedance

%% ===== Current Distribution =====
N = 200;                   % Number of segments
z = linspace(-L/2, L/2, N)';
dz = z(2) - z(1);

% Improved current distribution (sinusoidal + end correction)
I = sin(k*(L/2 - abs(z))) + 0.1*(cos(k*z) - cos(k*L/2)); 

%% ===== Self Impedance Numerical Calculation =====
R = abs(z - z');       % Distance matrix
R(R < a) = a;          % Avoid singularity
G = exp(-1j*k*R) ./ (4*pi*R);
integrand = I * I' .* G;
Z11_num = 1j * eta0 * k / (2*pi) * sum(integrand(:)) * dz^2 / sum(I.^2 * dz);

% Theoretical value for comparison
Z11_theory = 73.1 + 42.5i;

%% ===== Mutual Impedance Calculation =====
d_lambda = linspace(0.1, 3, 100);  % Normalized distances
d = d_lambda * lambda;

% Preallocate
Z12_num = zeros(size(d));
Z12_analytic = zeros(size(d));

for n = 1:length(d)
    R = sqrt(d(n)^2 + (z - z').^2);  % Distance matrix
    R(R < a) = a;                    % Handle singularities
    
    % Green's function kernel
    G = exp(-1j*k*R)./(4*pi*R);
    
    % Numerical mutual impedance
    integrand = I * I' .* G;
    Z12_num(n) = 1j*eta0*k/(2*pi) * sum(integrand(:)) * dz^2 / sum(I.^2*dz);
end

% Carter's analytical formula
beta = k;
for n = 1:length(d)
    u0 = beta*d(n);
    u1 = beta*(sqrt(d(n)^2 + L^2) + L);
    u2 = beta*(sqrt(d(n)^2 + L^2) - L);
    
    % Cosine and Sine integrals (approximate)
    Ci = @(x) -real(expint(1i*x)) - log(x) + 0.5772;
    Si = @(x) pi/2 - imag(expint(1i*x));
    
    Z12_analytic(n) = (30i/sind(beta*L/2)^2)*(2*Ci(u0)-Ci(u1)-Ci(u2)) ...
                     - 30*(2*Si(u0)-Si(u1)-Si(u2));
end

%% ===== Results Plotting =====
figure('Position', [100, 100, 900, 700]);

% Self-impedance comparison
subplot(3,1,1);
bar([real(Z11_num), imag(Z11_num); real(Z11_theory), imag(Z11_theory)], 'grouped');
legend('Numerical', 'Theoretical');
set(gca, 'XTickLabel', {'Real', 'Imaginary'});
ylabel('Impedance (\Omega)');
title(['Self-Impedance Z_{11}: Numerical = ', num2str(real(Z11_num), '%.1f'), ...
       ' + j', num2str(imag(Z11_num), '%.1f'), ' vs Theoretical = 73.1 + j42.5']);
grid on;

% Mutual impedance (real part)
subplot(3,1,2);
plot(d_lambda, real(Z12_num), 'b', 'LineWidth', 2); hold on;

xlabel('d/\lambda'); ylabel('Re(Z_{12}) (\Omega)');
title('Mutual Impedance (Real Part)');
legend('Numerical', 'Analytical (Carter)');
grid on;
ylim([-50 100]);

% Mutual impedance (imaginary part)
subplot(3,1,3);
plot(d_lambda, imag(Z12_num), 'b', 'LineWidth', 2); hold on;

xlabel('d/\lambda'); ylabel('Im(Z_{12}) (\Omega)');
title('Mutual Impedance (Imaginary Part)');
legend('Numerical', 'Analytical (Carter)');
grid on;
ylim([-50 50]);

%% ===== Impedance Magnitude/Phase =====
figure('Position', [200, 200, 800, 300]);

subplot(1,2,1);
plot(d_lambda, abs(Z12_num), 'LineWidth', 2);
xlabel('d/\lambda'); ylabel('|Z_{12}| [\Omega]');
title('Mutual Impedance Magnitude');
grid on;

subplot(1,2,2);
plot(d_lambda, angle(Z12_num)*180/pi, 'LineWidth', 2);
xlabel('d/\lambda'); ylabel('\angle Z_{12} [deg]');
title('Mutual Impedance Phase');
grid on;

%% ===== Display Results =====
fprintf('Numerical Z11 = %.2f + j%.2f Ω\n', real(Z11_num), imag(Z11_num));
fprintf('Theoretical Z11 = 73.10 + j42.50 Ω\n');
fprintf('Relative error: Re: %.1f%%, Im: %.1f%%\n', ...
        100*abs(real(Z11_num)-73.1)/73.1, ...
        100*abs(imag(Z11_num)-42.5)/42.5);