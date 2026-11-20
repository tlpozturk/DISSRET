
function [l_next] = solveLinearSystem_L(o, ir, uvx, uvy, alph)
    [h, w] = size(o);
    hw = h * w;
    
    uvx = uvx(:);
    uvy = uvy(:);
    ux = padarray(uvx, h, 'pre'); ux = ux(1:end-h);
    uy = padarray(uvy, 1, 'pre'); uy = uy(1:end-1);
    D = uvx + ux + uvy + uy;
    
    T = spdiags([-uvx, -uvy], [-h, -1], hw, hw);
    MN = T + T' + spdiags(D, 0, hw, hw);                    
    
    ir2 = ir.^2;                                        
    ir2 = spdiags(ir2(:), 0, hw, hw); 
    
    DEN = ir2 + alph * MN;  
    NUM = ir .* o;                            
    
    L = ichol(DEN, struct('michol', 'on'));    
    [l_next, ~] = pcg(DEN, NUM(:), 0.01, 40, L, L'); 
end