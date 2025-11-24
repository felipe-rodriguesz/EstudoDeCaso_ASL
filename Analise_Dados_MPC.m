%% Script de Análise de Dados e Métricas - MPC (CORRIGIDO)
clear; clc; close all;

%% 1. Carregar Dados do Caso NOMINAL
if isfile('Dados_MPC_Nominal.mat')
    load('Dados_MPC_Nominal.mat');
    
    % Extração da SAÍDA (Índice 1)
    signal_y = out.logsout.get(1).Values;
    t_y_nom = signal_y.Time;       % Tempo próprio da saída
    y_nom   = signal_y.Data;       % Dados da saída
    
    % Extração do CONTROLE (Índice 2)
    signal_u = out.logsout.get(2).Values;
    t_u_nom = signal_u.Time;       % Tempo próprio do controle (Aqui estava o erro!)
    u_nom   = signal_u.Data;       % Dados do controle
else
    error('Arquivo Dados_MPC_Nominal.mat não encontrado!');
end

%% 2. Carregar Dados do Caso ROBUSTO
if isfile('Dados_MPC_Robusto.mat')
    load('Dados_MPC_Robusto.mat');
    
    % Extração SAÍDA
    signal_y_rob = out.logsout.get(1).Values;
    t_y_rob = signal_y_rob.Time;
    y_rob   = signal_y_rob.Data;
    
    % Extração CONTROLE
    signal_u_rob = out.logsout.get(2).Values;
    t_u_rob = signal_u_rob.Time;
    u_rob   = signal_u_rob.Data;
else
    warning('Arquivo Dados_MPC_Robusto.mat não encontrado.');
    y_rob = y_nom; u_rob = u_nom; t_y_rob = t_y_nom; t_u_rob = t_u_nom;
end

%% 3. Gerar Gráfico Comparativo: SAÍDA (Ângulo)
figure(1); clf;
plot(t_y_nom, y_nom, 'b', 'LineWidth', 1.5); hold on;
plot(t_y_rob, y_rob, 'r--', 'LineWidth', 1.5);
yline(0.2, 'k:', 'LineWidth', 1); 

title('Comparação de Desempenho: Nominal vs. Robusto');
xlabel('Tempo (s)');
ylabel('Ângulo de Arfagem (rad)');
legend('Nominal', 'Robusto (Incerteza 40%)', 'Referência', 'Location', 'best');
grid on;
set(gcf, 'Color', 'w'); 

%% 4. Gerar Gráfico Comparativo: ESFORÇO DE CONTROLE
figure(2); clf;
% Agora usamos o tempo correto (t_u_nom) para o controle
plot(t_u_nom, u_nom, 'b', 'LineWidth', 1.5); hold on;
plot(t_u_rob, u_rob, 'r--', 'LineWidth', 1.5);
yline(0.35, 'k--'); yline(-0.35, 'k--'); 

title('Esforço de Controle (Profundor)');
xlabel('Tempo (s)');
ylabel('Deflexão (rad)');
legend('Nominal', 'Robusto', 'Limites (\pm 0.35)', 'Location', 'best');
grid on;
set(gcf, 'Color', 'w');

%% 5. Cálculo das Métricas (RMSE)
ref = 0.2;

% Para calcular erro, precisamos garantir que os vetores tenham mesmo tamanho.
% Vamos usar o último valor estável ou média simples se os tamanhos diferirem muito,
% mas para o RMSE geralmente pegamos o sinal direto.
erro_nom = ref - y_nom;
rmse_nom = sqrt(mean(erro_nom.^2));

erro_rob = ref - y_rob;
rmse_rob = sqrt(mean(erro_rob.^2));

fprintf('--- RESULTADOS DAS MÉTRICAS ---\n');
fprintf('RMSE Nominal: %.4f\n', rmse_nom);
fprintf('RMSE Robusto: %.4f\n', rmse_rob);
fprintf('-------------------------------\n');