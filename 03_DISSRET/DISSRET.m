function [R, L] = DISSRET(S, G)
% =========================================================================
% DISSRET - Dissimilarity Image Retinex Model
% 
% Girdi:
%   S - Giriş görüntüsünün parlaklık kanalı (Value channel)
%   G - Guidance matrisi (rehber matris)
%
% Çıktı:
%   R - Reflectance (yansıma) bileşeni
%   L - Illumination (aydınlatma) bileşeni
%
% Retinex Teorisi: S = R ∘ L (Giriş = Reflectance ∘ Illumination)
% =========================================================================

%% PARAMETRE TANIMLARI
alph = 0.0001;  % Illumination regülasyon parametresi
beta = 0.01;    % Reflectance regülasyon parametresi
%% GÖRÜNTÜ BOYUTLARI
[rows, columns] = size(S);

%% BAŞLANGIÇ DEĞERLERİ
% Illumination başlangıç değeri: giriş görüntüsü
L_pre = S;

% Reflectance başlangıç değeri: birim matris
R_pre = ones(rows, columns);

%% VEKTÖR FORMA DÖNÜŞÜM
% Giriş görüntüsü ve guidance matrisini vektör formuna çevir
o = S(:);  % Orijinal görüntü vektörü
g = G(:);  % Guidance matrisi vektörü

% Başlangıç değerlerini vektör formuna çevir
l_pre = L_pre(:);
l_next = l_pre;
r_pre = R_pre(:);
r_next = r_pre;

%% DİFERANSİYEL MATRİSLERİ HAZIRLA
% Reflectance için ikinci derece fark matrisi
Length_l = length(l_pre);
e = ones(Length_l, 1);
MN_r = spdiags([-e, 2*e, -e], [-1, 0, 1], Length_l, Length_l);

%% ITERATİF OPTİMİZASYON
for k = 1:5
fprintf('Iterasyon: %d\n', k);

%% REFLECTANCE BİLEŞENİ GÜNCELLEME
% -----------------------------------------------------------------
r_pre = r_next;

% Lineer sistem çözerek reflectance bileşenini güncelle
r_next = solveLinearSystem_R(o, l_next, MN_r, g, beta, Length_l);

% Vektörü matris formuna dönüştür
R_next = reshape(r_next, rows, columns);

%% ILLUMINATION BİLEŞENİ GÜNCELLEME
% -----------------------------------------------------------------
l_pre = l_next;

% Reflectance diagonal matrisini oluştur
r_diagonal_matrix = spdiags(r_next, 0, Length_l, Length_l);

% Geçici illumination hesapla: I = S / R
I = S ./ R_next;

% Yönlü benzerlik haritalarını hesapla
[diss_x, diss_y] = fast_dissimilarity2(I);

% Ağırlık matrislerini hazırla
ux = diss_x;      % X yönü ağırlıkları
uy = diss_y;      % Y yönü ağırlıkları

% Sınır piksellerini sıfırla
ux(:, end) = 0;
uy(end, :) = 0;

% Lineer sistem çözerek illumination bileşenini güncelle
l_next = solveLinearSystem_L(S, R_next, ux, uy, alph);

% Vektörü matris formuna dönüştür
L_next = reshape(l_next, rows, columns);

end

%% SONUÇLARI ATAMA
R = R_next;
L = L_next;

end