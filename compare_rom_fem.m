sims = ["p1fr1", "p5fr41", "p10fr17", "p12fr49", "p13fr54", "p14fr39", "p17fr31", "p23fr36", ...
   "p20fr9", "p20fr55", "p29fr43", "p34fr22", "p36fr30", "p39fr57", "p40fr13", "p40fr4", "p43fr37", ...
   "p48fr18", "p49fr5", "p50fr1"];
%sims =["p50fr1","p50fr1nd","p50fr1nd2","p50fr1newmark"];

for s = sims
    %load FEM
    load(strcat("FE/FE_results/",s,'.mat'))
    figure()
    grid on; hold on; box on
    plot(displacements(1:20001,1),displacements(1:20001,6),'b--','LineWidth',lw,'MarkerSize',5)
    xlabel('Time [s]','FontSize',fs)
    
    %load POD
    load(strcat('ROM_results/RO_',s,'.mat'))
    plot(timefactor*tconv,-r*Du_mid,'r--','LineWidth',lw,'MarkerSize',5);
end

