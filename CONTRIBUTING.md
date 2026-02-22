# Contributing to Muharrir

Muharrir'e katkıda bulunmak istediğiniz için teşekkürler! Bu rehber, katkı sürecini kolaylaştırmak için hazırlanmıştır.

## Geliştirme Ortamı

### Gereksinimler

- macOS 13+
- Swift 6.0+
- [Ollama](https://ollama.ai) (çalışan modeller için)
- [SwiftLint](https://github.com/realm/SwiftLint) (`brew install swiftlint`)

### Kurulum

```bash
git clone https://github.com/alpozcan/muharrir.git
cd muharrir
swift build
swift test
```

### Pre-commit Hook

Projeye bir pre-commit hook dahildir. İlk klonlamadan sonra etkinleştirmek için:

```bash
cp scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

Bu hook, her commit öncesinde `swiftlint --strict` çalıştırır.

## Katkı Süreci

1. **Issue açın** — Değişikliği tartışmak için önce bir issue oluşturun
2. **Fork & branch** — Kendi fork'unuzda bir feature branch oluşturun
3. **Değişiklikleri yapın** — Kod yazın ve testler ekleyin
4. **Lint kontrolü** — `swiftlint --strict` ile sıfır hata olduğundan emin olun
5. **Testler** — `swift test` ile tüm testlerin geçtiğini doğrulayın
6. **Pull request açın** — Değişikliklerinizi açıklayan bir PR oluşturun

## Kod Standartları

- **SwiftLint**: `.swiftlint.yml` konfigürasyonuna uyun. CI, `--strict` modunda çalışır.
- **Testler**: Yeni özellikler ve hata düzeltmeleri için test yazın. Mevcut testleri bozmayın.
- **Commit mesajları**: Kısa, açıklayıcı ve İngilizce yazın (ör. "Add search result pagination")
- **Türkçe**: Kullanıcıya gösterilen metin ve prompt'lar Türkçe olmalıdır.
- **Teknik terimler**: Swift/iOS terimleri (async, protocol, view, struct vb.) çevrilmeden bırakılmalıdır.

## Proje Yapısı

```
Sources/muharrir/
├── Muharrir.swift          # Ana giriş noktası ve komut tanımı
├── Commands/               # CLI alt komutları (check, review, improve, ...)
└── Core/
    ├── Checker.swift       # Paragraf çıkarma ve LLM denetim mantığı
    ├── Config.swift        # Sabitler ve dosya yolları
    ├── OllamaExtensions.swift  # Ollama.Client uyumluluk uzantıları
    ├── Prompts.swift       # Türkçe sistem prompt'ları
    ├── Scraper.swift       # Web kazıma ve dosya yükleme
    ├── Terminal.swift      # Terminal çıktı formatlama
    └── VectorStore.swift   # Embedding tabanlı vektör deposu

Tests/MuharrirTests/        # Birim testleri
```

## Katkı Alanları

- Yeni Türkçe teknik yazım kuralları ve prompt iyileştirmeleri
- Ek komutlar veya mevcut komutlara yeni özellikler
- Performans iyileştirmeleri (chunking, similarity hesaplama)
- Daha fazla test kapsamı
- Belgeleme iyileştirmeleri

## Lisans

Katkılarınız, projenin [MIT lisansı](LICENSE) altında yayınlanacaktır.
