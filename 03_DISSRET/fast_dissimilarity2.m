
function [diss_horizontal, diss_vertical] = fast_dissimilarity2(img)
DN=2;

S=img*255;

% Yatay (1x3) ve dikey (3x1) filtreler
kernel_horizontal = ones(1, 3);  % Yatay filtre
kernel_vertical = ones(3, 1);    % Dikey filtre


GrayChannel = double(S(:, :, 1));


% Her bir kanal için yatay filtre uygula (1x3 pencereler)
meanGray_horizontal = conv2(GrayChannel, kernel_horizontal, 'same') ./ 3;


% Her bir kanal için dikey filtre uygula (3x1 pencereler)
meanGray_vertical = conv2(GrayChannel, kernel_vertical, 'same') ./ 3;


% Yatay pikseller farklarını hesapla
diffGray_horizontal = abs(GrayChannel - meanGray_horizontal);


% Dikey pikseller farklarını hesapla
diffGray_vertical = abs(GrayChannel - meanGray_vertical);


% Gaussian fonksiyonu ile yatay ve dikey benzerlikleri hesapla
diss_horizontal = 1 - (exp(-(diffGray_horizontal / DN).^2));
diss_vertical = 1 - (exp(-(diffGray_vertical / DN).^2));
    
%Düzeltme
eps=0.1;
gama=1.2;
diss_horizontal = (diss_horizontal + eps).^gama;
diss_horizontal = medfilt2(diss_horizontal, [3 3]);

diss_vertical = (diss_vertical + eps).^gama;
diss_vertical = medfilt2(diss_vertical, [3 3]);
end