clc
clear
close all

%% Parameters
lambda = 1;
k = 2*pi/lambda;

N_element = 7;                
d = 0.5*lambda;       
theta = 0:0.01:pi;
phi = 0:0.01:2*pi;

theta0 = pi/2;        
phi0 = 0;


[x_idx, y_idx] = meshgrid(0:N_element-1, 0:N_element-1);
x_pos = (x_idx - (N_element-1)/2)*d;
y_pos = (y_idx - (N_element-1)/2)*d;

%% Array Factor
AF = zeros(length(theta), length(phi));
for m = 1:N_element
    for n = 1:N_element
        alpha_mn = -k * (x_pos(m,n)*sin(theta0)*cos(phi0) + y_pos(m,n)*sin(theta0)*sin(phi0));
        for ti = 1:length(theta)
            for pi = 1:length(phi)
                psi = k * (x_pos(m,n)*sin(theta(ti))*cos(phi(pi)) + y_pos(m,n)*sin(theta(ti))*sin(phi(pi)));
                AF(ti, pi) = AF(ti, pi) + exp(1j*(psi + alpha_mn));
            end
        end
    end
end

F = abs(AF .* sin(theta.')).^2;
F = F / max(F(:)); 

%% θ=π/2 و φ=0
figure;
subplot(1,2,1)
polarplot(phi, 10*log10(F(round(length(theta)/2), :)))
title('\theta = \pi/2')
rlim([-30 0])

subplot(1,2,2)
polarplot(theta, 10*log10(F(:,1)))
title('\phi = 0')
rlim([-30 0])
set(gca, 'ThetaZeroLocation', 'top')

%% Directivity
d_vals = 0.2:0.1:1.2;
D0_db = [];

for d = d_vals
    x_pos = (x_idx - (N_element-1)/2)*d;
    y_pos = (y_idx - (N_element-1)/2)*d;
    U = zeros(length(theta), length(phi));
    P_rad = 0;

    for m1 = 1:N_element
        for n1 = 1:N_element
            for m2 = 1:N_element
                for n2 = 1:N_element
                    r1 = [x_pos(m1,n1), y_pos(m1,n1)];
                    r2 = [x_pos(m2,n2), y_pos(m2,n2)];
                    delta_r = r1 - r2;

                    for ti = 1:length(theta)
                        for pi = 1:length(phi)
                            psi = k * delta_r(1)*sin(theta(ti))*cos(phi(pi)) + k * delta_r(2)*sin(theta(ti))*sin(phi(pi));
                            U(ti,pi) = U(ti,pi) + sin(theta(ti))^2 * exp(1j * psi);
                        end
                    end
                end
            end
        end
    end

    for ti = 1:length(theta)
        for pi = 1:length(phi)
            P_rad = P_rad + abs(U(ti,pi)) * sin(theta(ti)) * 0.01 * 0.01;
        end
    end

    D0 = max(abs(U(:))) / (P_rad / (4*pi));
    D0_db = [D0_db, 10*log10(D0)];
end

figure;
plot(d_vals/lambda, D0_db, 'LineWidth', 2)
xlabel('d/\lambda')
ylabel('Directivity (dB)')
title('Directivity vs. Element Spacing in Square Array')
grid on
