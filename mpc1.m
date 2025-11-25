%% create MPC controller object with sample time
mpc1 = mpc(plant_C, 0.1);
%% specify prediction horizon
mpc1.PredictionHorizon = 10;
%% specify control horizon
mpc1.ControlHorizon = 2;
%% specify nominal values for inputs and outputs
mpc1.Model.Nominal.U = 0;
mpc1.Model.Nominal.Y = 0;
%% specify constraints for MV and MV Rate
mpc1.MV(1).Min = -0.35;
mpc1.MV(1).Max = 0.35;
%% specify overall adjustment factor applied to weights
beta = 6.821;
%% specify weights
mpc1.Weights.MV = 0*beta;
mpc1.Weights.MVRate = 0.1/beta;
mpc1.Weights.OV = 1*beta;
mpc1.Weights.ECR = 100000;
%% specify simulation options
options = mpcsimopt();
options.RefLookAhead = 'off';
options.MDLookAhead = 'off';
options.Constraints = 'on';
options.OpenLoop = 'off';
%% run simulation
sim(mpc1, 101, mpc1_RefSignal, mpc1_MDSignal, options);
