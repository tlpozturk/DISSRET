
function [diss] = fast_dissimilarity(img)
DN=8;

% Görüntü boyutlarını al
[h, w, ~] = size(img);

% Pencereler için filtreyi oluştur (3x3 komşular)
kernel = ones(3, 3);

% RGB kanalları için benzerlik matrislerini hesapla
redChannel = double(img(:, :, 1));
greenChannel = double(img(:, :, 2));
blueChannel = double(img(:, :, 3));

% Her bir kanal için filtre uygula (komşular)
meanRed = (conv2(redChannel, kernel, 'same'))./9 ;
meanGreen = (conv2(greenChannel, kernel, 'same'))./9;
meanBlue = (conv2(blueChannel, kernel, 'same'))./9;

% Piksel farklarını hesapla
diffRed = (redChannel - meanRed).^2;
diffGreen = (greenChannel - meanGreen).^2;
diffBlue = (blueChannel - meanBlue).^2;

% Oklid mesafesini tüm pikseller için hesapla
dist = sqrt(diffRed + diffGreen + diffBlue);

% Gaussian fonksiyonu ile benzerlik hesapla
sim = exp(-(dist / DN).^2);


%Düzeltme
eps=0.001;
gama=2.2;
sim=(sim+eps).^gama;
sim=medfilt2(sim, [3 3]);
diss = 1 - sim;

end