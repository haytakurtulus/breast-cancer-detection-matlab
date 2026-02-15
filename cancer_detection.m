clear; clc; close all;

% 1. DOSYAYI OTOMATİK BULMA VE YÜKLEME
fprintf('Veri seti aranıyor...\n');

% Klasördeki potansiyel isimleri kontrol et
if exist('kanser_verisi.csv', 'file')
    dosyaAdi = 'kanser_verisi.csv';
else
    % İsim tutmuyorsa klasördeki ilk .data veya .csv dosyasını al
    dosyalar = dir('*.data');
    if isempty(dosyalar)
        dosyalar = dir('*.csv');
    end
    
    if ~isempty(dosyalar)
        dosyaAdi = dosyalar(1).name;
        fprintf('Uyarı: Aranan isim bulunamadı ama "%s" bulundu, bu kullanılıyor.\n', dosyaAdi);
    else
        error('HATA: Klasörde veri dosyası bulunamadı! Lütfen wdbc.data dosyasını bu klasöre at.');
    end
end

fprintf('"%s" dosyası yükleniyor...\n', dosyaAdi);

% Dosyayı Oku 
data = readtable(dosyaAdi, 'FileType', 'text', 'ReadVariableNames', true);


% 3. ÖZELLİK SEÇİMİ (ID silme)
data.ID = [];

% Girdi ve Çıktı Ayrımı
X = data(:, 2:end);
Y = data.Diagnosis;

% 4. EĞİTİM VE TEST AYRIMI (%30 Test)
cv = cvpartition(Y, 'HoldOut', 0.3);
X_train = X(training(cv), :);
Y_train = Y(training(cv), :);
X_test = X(test(cv), :);
Y_test = Y(test(cv), :);

% 5. EĞİTİM
fprintf('Model eğitiliyor (Gini Algoritması)...\n');
treeModel = fitctree(X_train, Y_train, 'Prune', 'on', 'PredictorNames', X.Properties.VariableNames);

% 6. GÖRSELLEŞTİRME
view(treeModel, 'Mode', 'graph');

% 7. TEST
Y_pred = predict(treeModel, X_test);
figure;
confusionchart(Y_test, Y_pred);
title('Test Sonuçları');

acc = sum(strcmp(Y_pred, Y_test)) / length(Y_test) * 100;
fprintf('\nBAŞARI ORANI: %%%.2f\n', acc);