% 1. Carrega o Nominal
load('Dados_MPC_Nominal.mat');

sinal_1_nominal = out.logsout.get(1).Values.Data; 
sinal_2_nominal = out.logsout.get(2).Values.Data;

% 2. Carrega o Robusto
load('Dados_MPC_Robusto.mat');
sinal_1_robusto = out.logsout.get(1).Values.Data;
sinal_2_robusto = out.logsout.get(2).Values.Data;

% 3. Descobrir quem é quem (Plotar para confirmar)
figure;
subplot(2,1,1);
plot(sinal_1_nominal); title('Sinal 1 (Verifique se é Saída ou Controle)');
subplot(2,1,2);
plot(sinal_2_nominal); title('Sinal 2');
