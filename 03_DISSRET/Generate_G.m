
function [G] = Generate_G(I, diss)
    eps = 0.001;
    sim = 1 - diss;
    sim(sim < eps) = 0;
    G = sim;
end