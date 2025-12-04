%% SCRIPT: GERAÇÃO DE 4 FIGURAS SEPARADAS DE MÉTRICAS (PID vs MPC)
clc; clear; close all;

% --- 1. DEFINIÇÃO DA PLANTA (Igual ao seu modelo) ---
A = [-0.313   56.7    0;
     -0.0139 -0.426   0;
      0       56.7    0];
B = [0.232; 0.0203; 0];
C = [0 0 1]; D = [0];
sys_aviao = ss(A,B,C,D);
Ts = 0.1; 

% --- 2. SIMULAÇÃO PID ---
Kp = 1.2; Ki = 0.5; Kd = 0.8; % Se tiver valores melhores, troque aqui
C_pid = pid(Kp, Ki, Kd);
sys_cl_pid = feedback(sys_aviao * C_pid, 1);
t = 0:Ts:10;         
r = 0.2 * ones(size(t)); 
[y_pid, t_pid] = lsim(sys_cl_pid, r, t);
e_pid = r' - y_pid;      

% --- 3. SIMULAÇÃO MPC ---
if exist('mpc1', 'var')
    mpc_obj = mpc1; % Usa o seu se estiver na memória
else
    % Cria um temporário se não houver
    mpc_obj = mpc(sys_aviao, Ts);
    mpc_obj.PredictionHorizon = 10;
    mpc_obj.ControlHorizon = 2;
    mpc_obj.Weights.OutputVariables = 10;
end
opt = mpcsimopt();
[y_mpc, t_mpc, ~] = sim(mpc_obj, length(t), 0.2, opt);
e_mpc = 0.2 - y_mpc; 

% --- 4. CÁLCULO DAS MÉTRICAS ---
calc_metric = @(erro, tipo) cumtrapz(t, (tipo==1).*abs(erro) + ...     % 1=IAE
                                        (tipo==2).*(erro.^2) + ...     % 2=ISE
                                        (tipo==3).*(t'.*abs(erro)));   % 3=ITAE

iae_pid = calc_metric(e_pid, 1); iae_mpc = calc_metric(e_mpc, 1);
ise_pid = calc_metric(e_pid, 2); ise_mpc = calc_metric(e_mpc, 2);
itae_pid = calc_metric(e_pid, 3); itae_mpc = calc_metric(e_mpc, 3);
rmse_pid = sqrt(ise_pid ./ (t' + eps)); rmse_mpc = sqrt(ise_mpc ./ (t' + eps));

% Configuração padrão para estética
LineW = 2.0; % Linha grossa para ficar bom no artigo
FontSize = 12;

% --- 5. GERAÇÃO DAS 4 FIGURAS SEPARADAS ---

% === FIGURA 1: IAE ===
f1 = figure('Name', 'IAE', 'Color', 'w');
plot(t, iae_pid, 'r', 'LineWidth', LineW); hold on;
plot(t, iae_mpc, 'b--', 'LineWidth', LineW);
title('IAE (Integral do Erro Absoluto)', 'FontSize', FontSize);
xlabel('Tempo (s)'); ylabel('Erro Acumulado');
legend('PID', 'MPC', 'Location', 'Best'); grid on;
exportgraphics(f1, 'IAE.png', 'Resolution', 300);

% === FIGURA 2: ISE ===
f2 = figure('Name', 'ISE', 'Color', 'w');
plot(t, ise_pid, 'r', 'LineWidth', LineW); hold on;
plot(t, ise_mpc, 'b--', 'LineWidth', LineW);
title('ISE (Integral do Erro Quadrático)', 'FontSize', FontSize);
xlabel('Tempo (s)'); ylabel('Erro Acumulado');
legend('PID', 'MPC', 'Location', 'Best'); grid on;
exportgraphics(f2, 'ISE.png', 'Resolution', 300);

% === FIGURA 3: ITAE ===
f3 = figure('Name', 'ITAE', 'Color', 'w');
plot(t, itae_pid, 'r', 'LineWidth', LineW); hold on;
plot(t, itae_mpc, 'b--', 'LineWidth', LineW);
title('ITAE (Erro Ponderado pelo Tempo)', 'FontSize', FontSize);
xlabel('Tempo (s)'); ylabel('Erro Acumulado');
legend('PID', 'MPC', 'Location', 'Best'); grid on;
exportgraphics(f3, 'ITAE.png', 'Resolution', 300);

% === FIGURA 4: RMSE ===
f4 = figure('Name', 'RMSE', 'Color', 'w');
plot(t, rmse_pid, 'r', 'LineWidth', LineW); hold on;
plot(t, rmse_mpc, 'b--', 'LineWidth', LineW);
title('RMSE (Raiz do Erro Quadrático Médio)', 'FontSize', FontSize);
xlabel('Tempo (s)'); ylabel('Magnitude do Erro');
legend('PID', 'MPC', 'Location', 'Best'); grid on;
exportgraphics(f4, 'RMSE.png', 'Resolution', 300);

disp('Concluído! As 4 imagens (IAE.png, ISE.png, ITAE.png, RMSE.png) foram salvas.');