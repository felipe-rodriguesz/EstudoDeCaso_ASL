clear all; clc; close all;
%% 1. Definição do Modelo (Matrizes Numéricas do CTMS)
% Fonte: https://ctms.engin.umich.edu/CTMS/index.php?example=AircraftPitch&section=SystemModeling
% Substituímos as equações físicas pelos valores exatos do tutorial
% para garantir que os gráficos (Root Locus) fiquem didáticos e corretos.

A = [-0.313   56.7    0;
     -0.0139 -0.426   0;
      0       56.7    0];

B = [0.232;
     0.0203;
     0];

C = [0 0 1];
D = 0;

% Criação do Sistema no MATLAB
sys_aviao = ss(A,B,C,D);

sys_aviao.TimeUnit = ''; 
% -----------------------------------

%% 2. Configuração de Estética
set(0, 'DefaultAxesFontSize', 12);      
set(0, 'DefaultTextFontSize', 12);      
set(0, 'DefaultLineLineWidth', 1.5);      
set(0, 'DefaultFigureColor', 'w');      
set(0, 'DefaultAxesColor', 'w');        
set(0, 'DefaultAxesXColor', 'k');       
set(0, 'DefaultAxesYColor', 'k');       

%% 3. Gráfico 1: Resposta ao Degrau
figure(1); clf;
t = 0:0.1:50;
opt = stepDataOptions('StepAmplitude', 0.2); 

step(sys_aviao, t, opt);

title('Resposta ao Degrau (Malha Aberta)');
ylabel('Ângulo de Arfagem \theta (rad)');
xlabel('Tempo (s)');
grid on;
exportgraphics(gcf, 'degrau.png', 'Resolution', 300);

%% 4. Gráfico 2: Lugar das Raízes
figure(2); clf;
rlocus(sys_aviao);

title('Lugar das Raízes');
xlabel('Eixo Real');      
ylabel('Eixo Imaginário');
axis equal;
grid on;
exportgraphics(gcf, 'rootlocus.png', 'Resolution', 300);

%% 5. Gráfico 3: Diagrama de Bode
figure(3); clf;
h = bodeplot(sys_aviao);

% Forçar títulos em português manualmente
opts = getoptions(h);
opts.Title.String = 'Diagrama de Bode';
opts.XLabel.String = 'Frequência'; 
opts.YLabel.String = {'Magnitude', 'Fase (graus)'};
setoptions(h, opts);

grid on;
exportgraphics(gcf, 'bode.png', 'Resolution', 300);