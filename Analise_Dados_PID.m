%% Script de Análise de Dados e Métricas - PID

%% 1. Carregar Dados do Caso NOMINAL
if isfile('Dados_PID_Nominal.mat')
    load('Dados_PID_Nominal.mat');
    
    % Extração da SAÍDA (Índice 1 - Ângulo)
    signal_y = out.logsout.get(1).Values;
    t_y_nom = signal_y.Time;       
    y_nom   = signal_y.Data;       
    
    % Extração do CONTROLE (Índice 2 - Profundor)
    signal_u = out.logsout.get(2).Values;
    t_u_nom = signal_u.Time;       
    u_nom   = signal_u.Data;       
else
    error('Arquivo Dados_PID_Nominal.mat não encontrado! Rode o run_pid.m primeiro.');
end

%% 2. Carregar Dados do Caso ROBUSTO
if isfile('Dados_PID_Robusto.mat')
    load('Dados_PID_Robusto.mat');
    
    % Extração
    signal_y_rob = out.logsout.get(1).Values;
    t_y_rob = signal_y_rob.Time;
    y_rob   = signal_y_rob.Data;
    
    signal_u_rob = out.logsout.get(2).Values;
    t_u_rob = signal_u_rob.Time;
    u_rob   = signal_u_rob.Data;
else
    warning('Arquivo Dados_PID_Robusto.mat não encontrado.');
    y_rob = y_nom; u_rob = u_nom; t_y_rob = t_y_nom; t_u_rob = t_u_nom;
end

%% 3. Gráfico 1: Comparação de Saída (PID)
figure(1); clf;
plot(t_y_nom, y_nom, 'b', 'LineWidth', 1.5); hold on;
plot(t_y_rob, y_rob, 'r--', 'LineWidth', 1.5);
yline(0.2, 'k:', 'LineWidth', 1); % Referência

title('PID: Desempenho Nominal vs. Robusto');
xlabel('Tempo (s)');
ylabel('Ângulo de Arfagem (rad)');
legend('Nominal', 'Robusto (Incerteza 40%)', 'Referência', 'Location', 'best');
grid on;
set(gcf, 'Color', 'w'); 
% exportgraphics(gcf, 'PID_Comparativo_Saida.png', 'Resolution', 300);

%% 4. Gráfico 2: Esforço de Controle (PID)
figure(2); clf;
plot(t_u_nom, u_nom, 'b', 'LineWidth', 1.5); hold on;
plot(t_u_rob, u_rob, 'r--', 'LineWidth', 1.5);

% Linhas de limite físico (só para mostrar se o PID violou)
yline(0.35, 'k--'); yline(-0.35, 'k--'); 

title('PID: Esforço de Controle (Profundor)');
xlabel('Tempo (s)');
ylabel('Deflexão (rad)');
legend('Nominal', 'Robusto', 'Limites Físicos (\pm 0.35)', 'Location', 'best');
grid on;
set(gcf, 'Color', 'w');
% exportgraphics(gcf, 'PID_Comparativo_Controle.png', 'Resolution', 300);

%% 5. Cálculo das Métricas (RMSE)
ref = 0.2;

% Cálculo do RMSE
erro_nom = ref - y_nom;
rmse_nom = sqrt(mean(erro_nom.^2));

erro_rob = ref - y_rob;
rmse_rob = sqrt(mean(erro_rob.^2));

% Cálculo do ITAE (Integral do Tempo x Erro Absoluto) - Opcional mas bom pro artigo
itae_nom = trapz(t_y_nom, t_y_nom .* abs(erro_nom));
itae_rob = trapz(t_y_rob, t_y_rob .* abs(erro_rob));

fprintf('--- RESULTADOS DAS MÉTRICAS (PID) ---\n');
fprintf('RMSE Nominal: %.4f\n', rmse_nom);
fprintf('RMSE Robusto: %.4f\n', rmse_rob);
fprintf('ITAE Nominal: %.4f\n', itae_nom);
fprintf('ITAE Robusto: %.4f\n', itae_rob);
fprintf('-------------------------------------\n');