%%
%% 1. Definição do Modelo (Matrizes Numéricas do CTMS)
A = [-0.313   56.7    0;
     -0.0139 -0.426   0;
      0       56.7    0];
B = [0.232;
     0.0203;
     0];
C = [0 0 1];
D = [0];
sys_aviao = ss(A,B,C,D);
sys_aviao.TimeUnit = '';
%% --------------------------------------------------------
%% 2. Configuração de Estética (AJUSTADO PARA GARANTIR PRETO E BRANCO)
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultTextFontSize', 12);
set(0, 'DefaultLineLineWidth', 1.5);
set(0, 'DefaultFigureColor', 'w');    % Garante fundo da janela branco
set(0, 'DefaultAxesColor', 'w');      % Garante fundo do gráfico branco
set(0, 'DefaultAxesXColor', 'k');     % Eixo X Preto
set(0, 'DefaultAxesYColor', 'k');     % Eixo Y Preto
set(0, 'DefaultTextColor', 'k');      % Garante que Textos/Títulos sejam Pretos
%% --------------------------------------------------------
%% 3. Gráfico 1: Resposta ao Degrau
figure(1); clf;
set(gcf, 'Color', 'w'); % Força fundo branco na figura atual
t = 0:0.1:50;
opt = stepDataOptions('StepAmplitude', 0.2);
step(sys_aviao, t, opt);
title('Resposta ao Degrau (Malha Aberta)', 'Color', 'k');
ylabel('Ângulo de Arfagem \theta (rad)', 'Color', 'k');
xlabel('Tempo (s)', 'Color', 'k');
grid on;
% Adicionado BackgroundColor white para garantir no arquivo salvo
exportgraphics(gcf, 'degrau.png', 'Resolution', 300, 'BackgroundColor', 'white');
%% --------------------------------------------------------
%% 4. Gráfico 2: Lugar das Raízes
figure(2); clf;
set(gcf, 'Color', 'w');
rlocus(sys_aviao);
title('Lugar das Raízes', 'Color', 'k');
xlabel('Eixo Real', 'Color', 'k');
ylabel('Eixo Imaginário', 'Color', 'k');
axis equal;
grid on;
exportgraphics(gcf, 'rootlocus.png', 'Resolution', 300, 'BackgroundColor', 'white');
%% --------------------------------------------------------
%% 5. Diagrama de Bode
figure(3); clf;
set(gcf, 'Color', 'w');
h = bodeplot(sys_aviao);
opts = getoptions(h);
opts.Title.String = 'Diagrama de Bode';
opts.Title.Color = 'k';      % Força cor do título
opts.XLabel.String = 'Frequência';
opts.XLabel.Color = 'k';
opts.YLabel.String = {'Magnitude', 'Fase'};
opts.YLabel.Color = 'k';
opts.TickLabel.Color = 'k';  % Força cor dos números
setoptions(h, opts);
grid on;
exportgraphics(gcf, 'bode.png', 'Resolution', 300, 'BackgroundColor', 'white');
%% 6 — CARREGAR MPC E SIMULAR MODELO PID
plant_C = sys_aviao;
run('mpc1.m'); % Carrega MPC externo
disp('Controlador MPC carregado a partir do arquivo externo!');
model = 'ControlePIDAviaoSpecto';
open_system(model);
out = sim(model);
%% --------------------------------------------------------
%% 7. Espectrograma do Sinal de Controle u(t) — Adaptativo
try
    data_struct = out.u_t;
    if isstruct(data_struct) && isfield(data_struct, 'signals')
        u = data_struct.signals.values;
        t_u = data_struct.time;
    elseif isa(data_struct, 'timeseries')
        u = data_struct.Data;
        t_u = data_struct.Time;
    else
        error('Formato de dados não reconhecido.');
    end
    u = squeeze(u);
    len_u = length(u);
    figure(4); clf;
    set(gcf, 'Color', 'w'); % Força branco
    % Ajuste automático da janela
    if len_u < 256
        window_size = floor(len_u / 4);
        if window_size < 4, window_size = 4; end
        noverlap = floor(window_size * 0.75);
        nfft = 2^nextpow2(window_size * 2);
    else
        window_size = 256;
        noverlap = 200;
        nfft = 512;
    end
    window = hamming(window_size);
    % Frequência de amostragem
    if length(t_u) > 1
        dt = mean(diff(t_u)); if dt == 0, dt = 0.001; end
        Fs = 1/dt;
    else
        Fs = 1000;
    end
    % Spectrograma
    [s, f, t_spec] = spectrogram(u, window, noverlap, nfft, Fs);
    s_db = 20*log10(abs(s) + eps);
    imagesc(t_spec, f, s_db);
    set(gca, 'YDir', 'normal');
    set(gca, 'XColor', 'k', 'YColor', 'k'); % Força eixos pretos
    colormap(jet);
    c = colorbar;
    c.Color = 'k'; % Cor do texto da barra de cores
    ylabel(c, 'Magnitude (dB)', 'Color', 'k');
    title(sprintf('Espectrograma de u(t) — %d amostras', len_u), 'Color', 'k');
    xlabel('Tempo (s)', 'Color', 'k');
    ylabel('Frequência (Hz)', 'Color', 'k');
    max_val = max(s_db(:));
    caxis([max_val-60, max_val]);
    disp('Sucesso! Espectrograma de u(t) gerado.');
    exportgraphics(gcf, 'spectrogram_uPID.png', 'Resolution', 1080, 'BackgroundColor', 'white');
catch ME
    disp('ERRO NO ESPECTROGRAMA u(t):');
    disp(ME.message);
end
%% --------------------------------------------------------
%% 8 — Simulação MPC
model1 = 'Controle_MPC_AviaoSpecto';
open_system(model1);
out1 = sim(model1);
%% --------------------------------------------------------
%% 9. Espectrograma de u_MPC(t)
try
    data_struct1 = out1.u_mpc;
    if isstruct(data_struct1) && isfield(data_struct1, 'signals')
        u1 = data_struct1.signals.values;
        t_u1 = data_struct1.time;
    elseif isa(data_struct1, 'timeseries')
        u1 = data_struct1.Data;
        t_u1 = data_struct1.Time;
    else
        error('Formato MPC não reconhecido.');
    end
    u1 = squeeze(u1);
    len_u1 = length(u1);
    figure(5); clf;
    set(gcf, 'Color', 'w'); % Força branco
    % Janela dinâmica
    if len_u1 < 256
        window_size = floor(len_u1 / 4);
        if window_size < 4, window_size = 4; end
        noverlap = floor(window_size * 0.75);
        nfft = 2^nextpow2(window_size * 2);
    else
        window_size = 256;
        noverlap = 200;
        nfft = 512;
    end
    window = hamming(window_size);
    % Frequência de amostragem
    Fs = 1000;
    % Spectrograma
    [s, f, t_spec] = spectrogram(u1, window, noverlap, nfft, Fs);
    s_db = 20*log10(abs(s) + eps);
    
    % Nota: Mantive o '5' no imagesc conforme seu código original, 
    % mas para plotar no tempo correto o ideal seria usar 't_spec'.
    imagesc(5  , f, s_db); 
    
    set(gca, 'YDir', 'normal');
    set(gca, 'XColor', 'k', 'YColor', 'k'); % Força eixos pretos
    colormap(jet);
    c = colorbar;
    c.Color = 'k';
    ylabel(c, 'Magnitude (dB)', 'Color', 'k');
    title(sprintf('Espectrograma de u_{MPC}(t) — %d amostras', len_u1), 'Color', 'k');
    xlabel('Tempo (s)', 'Color', 'k');
    ylabel('Frequência (Hz)', 'Color', 'k');
    max_val = max(s_db(:));
    caxis([max_val-60, max_val]);
    disp('Sucesso! Espectrograma MPC gerado.');
    exportgraphics(gcf, 'spectrogram_u_mpcCorrigido.png', 'Resolution', 1080, 'BackgroundColor', 'white');
catch ME
    disp('ERRO NO ESPECTROGRAMA MPC:');
    disp(ME.message);
end