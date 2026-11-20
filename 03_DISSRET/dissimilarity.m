
function [diss] = dissimilarity(img)
    DN = 32; % Distance normalization
    h = size(img, 1); % Görüntünün satır sayısı (height)
    w = size(img, 2); % Görüntünün sütun sayısı (width)
    
    SimMat = zeros(h, w); % Similarity matrisi
    
    % Tüm pixeller için benzerlik hesaplanıyor
    for j = 1:h
        for i = 1:w
            maskRed = zeros(1, 9);
            maskGreen = zeros(1, 9);
            maskBlue = zeros(1, 9);
            
            % Komşu piksellerin RGB değerlerini al
            for b = 1:9
                x = ikomsu(b, i);
                y = jkomsu(b, j);
                
                % Komşu pikselin sınırda olup olmadığını kontrol et
                if resimdemi(x, y, w, h) == 1
                    % Eğer komşu piksel geçerli ise RGB değerlerini al
                    maskRed(b) = double(img(y, x, 1));
                    maskGreen(b) = double(img(y, x, 2));
                    maskBlue(b) = double(img(y, x, 3));
                else
                    maskRed(b) = 0;
                    maskGreen(b) = 0;
                    maskBlue(b) = 0;
                end
            end
            
            % Benzersizlik hesaplama
            Toplam = 0;
            for b = 1:9
                for c = 1:9
                    sim = similarity3(maskRed(b), maskGreen(b), maskBlue(b), maskRed(c), maskGreen(c), maskBlue(c), DN);
                    Toplam = Toplam + sim;
                end
            end
            SimMat(j, i) = Toplam / 81; % Ortalama benzerlik değeri
        end
    end
    
    sim = SimMat;
    diss = 1 - sim; % NOKTALI VİRGÜL EKLENDİ
end