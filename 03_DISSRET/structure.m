function [St] = structure(diss)
eps=0.01;
gama=2.2;
St=(diss+eps).^gama;
St=medfilt2(St, [3 3]);
end

