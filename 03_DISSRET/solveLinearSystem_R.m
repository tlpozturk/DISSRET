
function [r_next] = solveLinearSystem_R(o, l_next, MN_r, g, beta, Length_l)
    l_diagonal_matrix = spdiags(l_next, 0, Length_l, Length_l);
    DEN = l_diagonal_matrix.^2 + beta * (MN_r * MN_r');
    DEN = sparse(DEN);

    NUM = l_next .* o + beta * (MN_r' * g);
    
    try
        L = ichol(DEN, struct('michol', 'on'));
        [r_next, flag] = pcg(DEN, NUM(:), 1e-2, 20, L, L');
    catch
        [r_next, flag] = gmres(DEN, NUM(:), 10, 1e-2, 20);
    end
    
    if flag ~= 0
        warning('Çözücü yakınsama sağlamadı, flag: %d', flag);
    end
end