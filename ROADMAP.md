# Market Listem — Ürün Yol Haritası

## Faz 1 · Çalışan ürün döngüsü

- [x] SwiftData ürün ve satın alma geçmişi modelleri
- [x] `Evde → Azalıyor → Alınacak → Alındı → Evde` durum akışı
- [x] Liste, Ev ve Geçmiş ana navigasyonu
- [x] Hızlı ürün ekleme, yerel kategori tahmini ve duplicate kontrolü
- [x] Kategori bazlı market listesi, swipe aksiyonları ve alışveriş modu
- [x] Azalanlar, hızlı eksik ekleme ve sık alınana göre yerel sıralama
- [x] Ürün adedi/kategorisi düzenleme, boş durumlar ve haptic geri bildirim
- [x] Hızlı ürünler için renkli yerel illüstrasyonlar ve kategori bazlı sembol fallback'i

## Faz 2 · Kalite ve güven

- [x] InventoryService için unit test target'ı ve durum geçiş testleri
- [x] UI testleri: ekle, duplicate engelle, satın al, tekrar ekle
- [x] VoiceOver sırası, Dynamic Type ve koyu tema görsel denetimi
- [x] SwiftData migration planı ve hata görünürlüğü
- [x] Türkçe ürün sözlüğünü genişletme ve yazım varyasyonları

## Faz 3 · Kullanım kolaylığı

- [x] Hızlı ekleme sonuç mesajları ve geri alma aksiyonu
- [x] Liste içi arama ve isteğe bağlı kategori filtresi
- [x] Alışveriş modu için ilerleme göstergesi ve tamamlananlar alanı
- [x] Ürün silme / arşivleme kararı ve yönetim akışı
- [x] İlk kullanım için kısa, atlanabilir yönlendirme
- [x] Ürün eklerken adet seçimi ve widget'ta güncel market listesi

## Faz 4 · Yayına hazırlık

- [x] App icon, launch görünümü ve mağaza görselleri
- [x] Gizlilik metni, privacy manifest ve App Store metadata taslağı
- [x] Türkçe ve İngilizce uygulama/Widget yerelleştirmesi
- [ ] Gerçek cihaz performans, enerji ve erişilebilirlik kontrolleri
- [ ] TestFlight geri bildirim turu ve ilk sürüm kapsam kilidi

İlk sürüm local-first kalır; hesap, backend, CloudKit ve harici API kapsam dışıdır.
