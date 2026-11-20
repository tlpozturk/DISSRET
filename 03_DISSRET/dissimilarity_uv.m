
function [DissMat_h, DissMath_v] =dissimilarity_uv(img)

%  ------BİRİNCİ AŞAMA SİMİLARTY RESMİNİN ELDE EDİLMESİ-------------

img=img*255;

h = size(img, 1); % Görüntünün satır sayısı (height)
w = size(img, 2); % Görüntünün sütun sayısı (width)
DN = 4; % Distance normalization

DissMat_h = zeros(h, w); % Similarity matrisi (düzeltilmiş sıralama)
DissMat_v = zeros(h, w);
% Filtreleri uygula
    kernel_horizontal = ones(1, 3) ;  % Yatay filtre
    kernel_vertical = ones(3, 1);    % Dikey filtre

Gray_horizontal = conv2(img, kernel_horizontal, 'same') ./ 3;
Gray_vertical = conv2(img, kernel_vertical, 'same') ./ 3;
% Tüm pixeller için benzerlik hesaplanıyor
for j = 2:h-1;
    for i = 2:w-1;
        maskGray_h = get_neighbors(Gray_horizontal, i, j, h, w);
        maskGray_v = get_neighbors(Gray_vertical, i, j, h, w);
        Toplam_h = sum(dissimilarity_2D(maskGray_h, maskGray_h(5), DN));
        Toplam_v = sum(dissimilarity_2D(maskGray_v, maskGray_v(5), DN));
        % Ortalama benzerlik değeri
        DissMat_h(j, i) = Toplam_h / 9;
        DissMat_v(j, i) = Toplam_v / 9;

    end
end



% Fonksiyonlar

% Komşuları almak için yardımcı fonksiyon
function [maskGray] = get_neighbors(img, i, j, h, w)
    % 3x3'luk komşuluk maskesi
    % Pikselleri dışa taşarsa sınırda 0 değerini kullan
    maskGray = zeros(9, 1);
    idx = 1;
    for dy = -1:1
        for dx = -1:1
            x = i + dx;
            y = j + dy;
            if (x >= 1 && x <= w && y >= 1 && y <= h)
                maskGray(idx) = img(y, x);
            end
            idx = idx + 1;
        end
    end
end


function [diss] = dissimilarity_2D(k, o, DN)
    % Oklid mesafesi hesaplama
    dist = abs(k - o);
    % Gaussian fonksiyonuna göre benzerlik
    sim = exp(- (dist / DN).^2);
    diss=1-sim
end

end
