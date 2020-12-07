% Place this file in the saved directory of the data you would like to plot
% Default location for the current release of the code is at ~/datalog/read_experiment_binary.m
% This script opens the binary datalogs for estimation and control which is saved by the Caltech Cassie software
%
% Author: Jenna Reher (jreher@caltech.edu)
% -------------------------------------------------------------------------------------------------------------

do_estimation = true;
do_standing = true;
do_walking = true;

rootpath = pwd;

%% Estimation
if do_estimation
    ndbge = 48;
    fileID = fopen(strcat(rootpath, '/estimation_log.bin'));
    raw = fread(fileID,'float');
    nlogse = floor(length(raw) / ndbge);
    
    te = zeros(1,nlogse);
    quat = zeros(4,nlogse);
    gyro = zeros(3,nlogse);
    accel = zeros(3,nlogse);
    v = zeros(3,nlogse);
    enc = zeros(14,nlogse);
    denc = zeros(14,nlogse);
    ach = zeros(2,nlogse);
    dach = zeros(2,nlogse);
    contact = zeros(2,nlogse);
    
    for i = 1:nlogse
        % Index in array
        j = ndbge * (i-1) + 1;
        
        % Extract values into proper sizes
        te(i)        = raw(j);
        quat(:,i)    = raw(j+1 : j+4);
        gyro(:,i)    = raw(j+5 : j+7);
        accel(:,i)    = raw(j+8 : j+10);
        v(:,i)       = raw(j+11 : j+13);
        enc(:,i)     = raw(j+14 : j+27);
        denc(:,i)    = raw(j+28 : j+41);
        ach(:,i)     = raw(j+42 : j+43);
        dach(:,i)    = raw(j+44 : j+45);
        contact(:,i) = raw(j+46 : j+47);
    end
    t0 = te(1);
    te = te - te(1);
    dte = gradient(te);
    
    figure(20000);
    plot(te,dte);
    xlabel('Time (s)');
    ylabel('Est dt (s)');
    ylim([0, 0.05]);
    
    figure(501);
    plot(te, gyro);
    xlabel('Time (s)');
    ylabel('Gyro (rad/s)');
    
    figure(5011);
    plot(te, accel);
    xlabel('Time (s)');
    ylabel('Accel (m/s/s)');
    
    figure(502);
    plot(te, v);
    xlabel('Time (s)');
    ylabel('Vel (m/s)');
    
    figure(503);
    plot(te, contact);
    xlabel('Time (s)');
    ylabel('Contact');
    ylim([-0.1, 1.1]);
    
    figure(504);
    plot(te, enc);
    xlabel('Time (s)');
    ylabel('Encoder (rad)');
    
    figure(505);
    plot(te, denc);
    xlabel('Time (s)');
    ylabel('DEncoder (rad/s)');
    
    figure(506);
    plot(te, ach);
    xlabel('Time (s)');
    ylabel('Ach defl (rad)');
    
    figure(507);
    plot(te, quat);
    xlabel('Time (s)');
    ylabel('Quaternion');
    
end

%% Standing
if do_standing
    ndbgc = 59;
    fileID = fopen(strcat(rootpath, '/stand_log.bin'));
    raw = fread(fileID,'float');
    nlogs = floor(length(raw) / ndbgc);
    
    tc = zeros(1,nlogs);
    ya = zeros(6,nlogs);
    dya = zeros(6,nlogs);
    yd = zeros(6,nlogs);
    dyd = zeros(6,nlogs);
    d2yd = zeros(6,nlogs);
    V = zeros(1,nlogs);
    u = zeros(10,nlogs);
    F = zeros(16,nlogs);
    delta = zeros(1,nlogs);
    
    for i = 1:nlogs
        % Index in array
        j = ndbgc * (i-1) + 1;
        
        % Extract values into proper sizes
        tc(i)     = raw(j);
        ya(:,i)   = raw(j+1 : j+6);
        dya(:,i)  = raw(j+7 : j+12);
        yd(:,i)   = raw(j+13 : j+18);
        dyd(:,i)  = raw(j+19 : j+24);
        d2yd(:,i) = raw(j+25 : j+30);
        V(i)      = raw(j+31);
        u(:,i)    = raw(j+32 : j+41);
        F(:,i)    = raw(j+42 : j+57);
        delta(i)  = raw(j+58);
    end
    tc = tc - t0;
    dtc = gradient(tc);
    
    figure(1500);
    plot(tc,dtc);
    xlabel('Time (s)');
    ylabel('Control dt (s)');
    ylim([0, 0.05]);
    
    figure(1501);
    plot(tc,u);
    ylabel('u (Nm)');
    xlabel('t (s)');
    
    figure(1502);
    plot(tc,ya)
    hold on;
    plot(tc,yd,'--')
    title('ya yd');
    
    figure(1503);
    plot(tc,dya)
    hold on;
    plot(tc,dyd,'--')
    title('dya dyd');
    
    figure(1504);
    plot(tc,d2yd);
    title('d2yd');
    
    figure(1505);
    plot(tc, F(1:2,:));
    xlabel('Time (s)');
    ylabel('Force (N or Nm)');
    title('Achilles Constraint');
    
    figure(1506);
    plot(tc, F(3:6,:));
    xlabel('Time (s)');
    ylabel('Force (N or Nm)');
    title('Rigid Constraint');
    
    figure(1507);
    subplot(2,1,1);
    plot(tc, F(7:11,:));
    ylabel('Left Force (N or Nm)');
    title('Foot Constraints');
    subplot(2,1,2);
    plot(tc, F(12:16,:));
    xlabel('Time (s)');
    ylabel('Right Force (N or Nm)');
   
    figure(1508);
    plot(tc,V);
    ylabel('V');
    xlabel('t (s)');
    
    figure(1509);
    plot(tc,delta);
    ylabel('CLF Relaxation');
    xlabel('t (s)');
end

%% Walking
if do_walking
    ndbgw = 81;
    fileID = fopen(strcat(rootpath, '/qp_walk_log.bin'));
    raw = fread(fileID,'float');
    nlogsw = floor(length(raw) / ndbgw);
    
    tw    = zeros(1,nlogsw);
    tau   = zeros(1,nlogsw);
    dtau  = zeros(1,nlogsw);
    ya_w  = zeros(9,nlogsw);
    dya_w = zeros(9,nlogsw);
    yd_w  = zeros(9,nlogsw);
    dyd_w = zeros(9,nlogsw);
    V_w   = zeros(1,nlogsw);
    u_w   = zeros(10,nlogsw);
    Fdes_w = zeros(11,nlogsw);
    delta_w = zeros(1,nlogsw);
    v_d_w = zeros(2,nlogsw);
    v_a_w = zeros(2,nlogsw);
    avg_v_w = zeros(2,nlogsw);
    raibert_w = zeros(3,nlogsw);
    uff_w = zeros(10,nlogsw);
    
    for i = 1:nlogsw
        % Index in array
        j = ndbgw * (i-1) + 1;
        
        % Extract values into proper sizes
        tw(i)        = raw(j);
        tau(:,i)     = raw(j+1);
        dtau(:,i)    = raw(j+2);
        ya_w(:,i)    = raw(j+3 : j+11);
        dya_w(:,i)   = raw(j+12 : j+20);
        yd_w(:,i)    = raw(j+21 : j+29);
        dyd_w(:,i)   = raw(j+30 : j+38);
        V_w(:,i)     = raw(j+39);
        u_w(:,i)     = raw(j+40 : j+49);
        Fdes_w(:,i)  = raw(j+50 : j+60);
        delta_w(:,i) = raw(j+61);
        v_d_w(:,i)   = raw(j+62 : j+63);
        v_a_w(:,i)   = raw(j+64 : j+65);
        avg_v_w(:,i) = raw(j+66 : j+67);
        raibert_w(:,i) = raw(j+68 : j+70);
        uff_w(:,i) = raw(j+71 : j+80);
    end
    tw = tw - t0;
    dtw = gradient(tw);
    
    figure(40000);
    plot(tw,dtw);
    xlabel('Time (s)');
    ylabel('Walk dt (s)');
    ylim([0, 0.05]);
    
    figure(40001);
    subplot(2,1,1);
    plot(tw, tau);
    ylabel('Tau');
    subplot(2,1,2);
    plot(tw, dtau);
    ylabel('dTau');
    xlabel('Time (s)');
    
    figure(500000);
    plot(tw, avg_v_w);
    ylabel('Velocity (m/s)');
    xlabel('Time (s)');
    title('Average step velocity');
    
    figure(500001);
    plot(tw, v_d_w, '--');
    hold on;
    plot(tw, v_a_w);
    ylabel('Velocity (m/s)');
    xlabel('Time (s)');
    title('Velocity actual/desired comparison');

    figure(40002);
    plot(tw, ya_w(1:2,:));
    hold on;
    plot(tw, yd_w(1:2,:), '--');
    ylabel('Angle (rad)');
    xlabel('Time (s)');
    title('Floating Base Outputs');
    
    figure(40003);
    plot(tw, ya_w([3,8],:));
    hold on;
    plot(tw, yd_w([3,8],:), '--');
    ylabel('Angle (rad)');
    xlabel('Time (s)');
    title('Hip Yaw Outputs');
    
    figure(40004);
    plot(tw, ya_w(4:5,:));
    hold on;
    plot(tw, yd_w(4:5,:), '--');
    ylabel('Angle (rad)');
    xlabel('Time (s)');
    title('Leg length Outputs');
    
    figure(40005);
    plot(tw, ya_w(6,:));
    hold on;
    plot(tw, yd_w(6,:), '--');
    ylabel('Angle (rad)');
    xlabel('Time (s)');
    title('Leg Angle Outputs');
    
    figure(40006);
    plot(tw, ya_w(7,:));
    hold on;
    plot(tw, yd_w(7,:), '--');
    ylabel('Angle (rad)');
    xlabel('Time (s)');
    title('Swing Roll Outputs');
    
    figure(40007);
    plot(tw, ya_w(9,:));
    hold on;
    plot(tw, yd_w(9,:), '--');
    ylabel('Angle (rad)');
    xlabel('Time (s)');
    title('Swing Foot Outputs');
    
    figure(40008);
    plot(tw, uff_w, '--');
    hold on;
    plot(tw, u_w);
    ylabel('Torque (Nm)');
    xlabel('Time (s)');
    title('Torque (-- Feedforward) (- Total)');
    
    figure(400075);
    plot(tw, Fdes_w);
    title('Desired constraint forces');
    
    figure(400085);
    plot(tw, raibert_w);
    title('Raibert Cartesian delta position');    
end




