% =========================================================================
% DISSIMILARITY IMAGE RETINEX (DISSRET) MODEL - GÖRÜNTÜ İYİLEŞTİRME
% =========================================================================
% Retinex Teorisi: Bir görüntüyü reflectance (yansıma) ve illumination 
% (aydınlatma) bileşenlerine ayırarak görüntü iyileştirme işlemi yapar.
% 
% Temel Formül: S = R ∘ I 
%   S: Giriş görüntü, R: Reflectance (nesne özellikleri), 
%   I: Illumination (ışık koşulları)
% =========================================================================

clear all; close all; clc;

fprintf('\n=== SIMRET Görüntü İyileştirme Başlatıldı ===\n');

% =========================================================================
% GİRİŞ GÖRÜNTÜSÜ (LOW-LIGHT IMAGE)
% =========================================================================
img = imread('Balloons.bmp');
figure, imshow(img);
title("Input Low-Light Image");

% =========================================================================
% İŞLEM SÜRESİ BAŞLAT
% =========================================================================
orijinal_timer = tic;

% =========================================================================
% TERS BENZERLİK GÖRÜNTÜSÜ - Dissimilarity Image
% =========================================================================
diss = fast_dissimilarity(img);
figure, imshow(diss);
title("Dissimilarity Image");

% =========================================================================
% HSV RENK UZAYINA DÖNÜŞÜM
% =========================================================================
img_hsv = rgb2hsv(img);
S = img_hsv(:,:,3);  % Value (parlaklık) kanalı

% =========================================================================
% DİKEY VE YATAY BENZERLİK GÖRÜNTÜLERİ
% =========================================================================
[diss_x, diss_y] = fast_dissimilarity2(S);
figure, imshow(diss_x);
title("Dissimilarity Image X - Vertical");
figure, imshow(diss_y);
title("Dissimilarity Image Y - Horizontal");

% =========================================================================
% REHBER MATRİSİ (GUIDANCE MATRİX)
% =========================================================================
G = Generate_G(S, diss);
figure, imshow(G);
title("Guidance Matrix");

% =========================================================================
% DISSRET MODELİ İLE AYRIŞTIRMA
% =========================================================================
method = "DISSRET";

% Reflectance ve Illumination bileşenlerini hesapla
[R, I] = DISSRET(S, G);

% Reflectance bileşeni
figure, imshow(R);
title("Reflectance Component");

% Illumination bileşeni (S = R * I formülünden)
I = S ./ R;
figure, imshow(I);
title("Illumination Component");

% =========================================================================
% GAMMA DÜZELTMESİ
% =========================================================================
gamma = 2.1;
I_gamma = I.^(1/gamma); % Illumination'a gamma düzeltmesi uygula
figure, imshow(I_gamma);
title("Gamma Corrected Illumination");

% =========================================================================
% İYİLEŞTİRİLMİŞ GÖRÜNTÜYÜ OLUŞTURMA
% =========================================================================
S_gamma = R .* I_gamma; % Yeni parlaklık kanalını hesapla

% HSV görüntüyü güncelle
hsv = rgb2hsv(img);    % Orijinal HSV görüntü
hsv(:,:,3) = S_gamma;  % Yeni parlaklık kanalını ata

% Sayısal kararlılık için sınır kontrolleri
hsv = real(hsv);
hsv(hsv < 0) = 0; % Negatif değerleri sıfırla
hsv(hsv > 1) = 1; % 1'den büyük değerleri 1 yap

% RGB'ye dönüştür
eIm = hsv2rgb(hsv);

% =========================================================================
% İYİLEŞTİRİLMİŞ ÇIKTI GÖRÜNTÜSÜNÜ GÖSTER
% =========================================================================
eIm = uint8(eIm * 255); % uint8 formatına çevir
figure, imshow(eIm);
title("Enhanced Output Image");

% =========================================================================
% İŞLEM SÜRESİNİ BİTİR
% =========================================================================
 dissret_time = toc(orijinal_timer); 

% =========================================================================
% KALİTE METRİKLERİNİ HESAPLA
% =========================================================================
Im = img; % Orijinal görüntü
if size(Im,3) == 3
    Im_gray = rgb2gray(Im);
else
    Im_gray = Im;
end

if size(eIm,3) == 3
    eIm_gray = rgb2gray(eIm);
else
    eIm_gray = eIm;
end

% RMSE (Root Mean Squared Error) Hesaplama
rmse_value = sqrt(mean((double(Im_gray(:)) - double(eIm_gray(:))).^2));

% PSNR (Peak Signal-to-Noise Ratio) Hesaplama
max_pixel = double(max(Im_gray(:)));
if max_pixel > 0
    psnr_value = 20 * log10(max_pixel / rmse_value);
else
    psnr_value = inf;
end

% SSIM (Structural Similarity Index Measure) Hesaplama
ssim_value = ssim(eIm_gray, Im_gray);

% Görüntü kalite metrikleri
deger_LOE = metric_LOE(Im, eIm);      % Lightness Order Error
deger_GMSD = metric_GMSD(Im, eIm);    % Gradient Magnitude Similarity Deviation
deger_NIQE = niqe(eIm);               % Natural Image Quality Evaluator
deger_ARISMC = metric_ARISMC(eIm);    % ARISMC metriği
deger_BTMQI = metric_BTMQI(eIm);      % BTMQI metriği

% Tüm metrikleri bir arada göster
fprintf('\n=== METRİK SONUÇLARI ===\n');
fprintf('RMSE: %.4f\n', rmse_value);
fprintf('PSNR: %.4f dB\n', psnr_value);
fprintf('SSIM: %.4f\n', ssim_value);
fprintf('LOE: %.4f\n', deger_LOE);
fprintf('GMSD: %.4f\n', deger_GMSD);
fprintf('NIQE: %.4f\n', deger_NIQE);
fprintf('ARISMC: %.4f\n', deger_ARISMC);
fprintf('BTMQI: %.4f\n', deger_BTMQI);
fprintf('\n=== DISSRET Görüntü İyileştirme Tamamlandı ===\n');
