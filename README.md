<p align="center">
  <h1 align="center">Yazman</h1>
  <p align="center">
    <em>Türkçe teknik makale yazım denetleyicisi — yerel LLM + RAG ile.</em>
  </p>
  <p align="center">
    <a href="https://github.com/alpozcan/yazman/releases" target="_blank"><img src="https://img.shields.io/github/v/release/alpozcan/yazman?style=flat-square&label=s%C3%BCr%C3%BCm" alt="Sürüm"></a>
    <a href="https://github.com/alpozcan/yazman/blob/main/Package.swift" target="_blank"><img src="https://img.shields.io/badge/SPM-uyumlu-orange?style=flat-square" alt="Swift Package Manager"></a>
    <a href="https://github.com/alpozcan/yazman/blob/main/Package.swift" target="_blank"><img src="https://img.shields.io/badge/Mint-uyumlu-brightgreen?style=flat-square" alt="Mint"></a>
    <a href="https://github.com/alpozcan/homebrew-yazman/blob/main/Formula/yazman.rb" target="_blank"><img src="https://img.shields.io/badge/Homebrew-tap-FBB040?style=flat-square&logo=homebrew&logoColor=white" alt="Homebrew"></a>
    <a href="https://swift.org" target="_blank"><img src="https://img.shields.io/badge/Swift-6.0+-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift 6.0+"></a>
    <a href="https://github.com/alpozcan/yazman/actions/workflows/ci.yml" target="_blank"><img src="https://img.shields.io/github/actions/workflow/status/alpozcan/yazman/ci.yml?style=flat-square&label=CI" alt="CI"></a>
    <a href="https://github.com/alpozcan/yazman/blob/main/LICENSE" target="_blank"><img src="https://img.shields.io/badge/lisans-MIT-97ca00?style=flat-square" alt="Lisans"></a>
  </p>
</p>

---

Yazman, Türkçe teknik makalelerin dilini ve ifade biçimini yerel bir LLM ([Ollama](https://ollama.ai)) ve RAG (Retrieval-Augmented Generation) kullanarak denetler, iyileştirme önerileri sunar. Tüm verileriniz makinenizde kalır; dışarıya hiçbir veri çıkmaz.

## Kurulum

### Homebrew

```bash
brew install alpozcan/yazman/yazman
```

### Mint

```bash
mint install alpozcan/yazman
```

### Kaynaktan Derleme (Swift Package Manager)

```bash
git clone https://github.com/alpozcan/yazman.git
cd yazman
swift build -c release
cp .build/release/yazman /usr/local/bin/
```

### Gereksinimler

Yazman'in çalışması için [Ollama](https://ollama.ai)'nın yerel olarak kurulu ve çalışır durumda olması gerekir:

```bash
brew install ollama
brew services start ollama
ollama pull gemma3:4b            # Metin üretimi modeli
ollama pull nomic-embed-text     # Embedding modeli
```

## Kullanım

### Corpus Oluşturma

Makaleleri corpus'a ekleyerek RAG bağlamını oluşturun:

```bash
# Yerel markdown dosyalarını ekle
yazman add makale.md diger-makale.md

# Web'den Türkçe teknik makaleleri tara
yazman scrape https://example.com/swift-makale

# Seed URL'lerden otomatik keşfet
yazman scrape --discover
```

### Dil Denetimi

```bash
# Paragraf paragraf dil kontrolü (RAG destekli)
yazman check makale.md

# RAG olmadan kontrol
yazman check makale.md --no-rag

# Bütünsel makale incelemesi
yazman review makale.md

# Somut kelime ve ifade iyileştirme önerileri
yazman improve makale.md
```

### Arama ve İstatistikler

```bash
# Corpus'ta anlamsal arama
yazman search "Swift macro kullanımı"

# Sonuç sayısını belirle
yazman search "async defer" -n 10

# Corpus ve model istatistikleri
yazman stats
```

## Sistem Mimarisi

```
┌──────────────────────────────────────────────────────────────────────┐
│                        CLI Katmanı (Sunum)                           │
│                                                                      │
│  check ∙ review ∙ improve ∙ search ∙ add ∙ scrape ∙ stats           │
│  ── swift-argument-parser ile AsyncParsableCommand ──                │
└──────────────────────────┬───────────────────────────────────────────┘
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
┌─────────────────┐ ┌────────────┐ ┌──────────────────┐
│   İçerik Girdi  │ │  Denetim   │ │  RAG Boru Hattı  │
│                 │ │  Motoru    │ │                  │
│ Scraper         │ │            │ │ VectorStore      │
│ ├ URL fetch     │ │ Checker    │ │ ├ Parçalama      │
│ ├ HTML parse    │ │ ├ Paragraf │ │ │ (500k/100k)    │
│ │ (SwiftSoup)   │ │ │ çıkarma  │ │ ├ Embedding      │
│ └ Makale cache  │ │ ├ RAG bağ- │ │ │ (nomic-embed)  │
│                 │ │ │ lam inşa │ │ ├ SIMD cosine    │
│ Add (yerel .md) │ │ └ LLM akış │ │ │ (Accelerate)   │
│                 │ │   çıktısı  │ │ └ JSON disk      │
└────────┬────────┘ └─────┬──────┘ └────────┬─────────┘
         │                │                  │
         │                │    Benzer        │
         │   Makale       │    Parçalar      │
         │   Metni        │  ◀───────────────┘
         │                │
         └───────────┐    │
                     ▼    ▼
          ┌──────────────────────────┐
          │      Ollama (Yerel)      │
          │                          │
          │  gemma3:4b    nomic-     │
          │  (üretim)    embed-text  │
          │              (embedding) │
          │                          │
          │  Lifecycle: brew svc     │
          │  start/stop + sinyal     │
          └──────────────────────────┘
                     │
                     ▼
          ┌──────────────────────────┐
          │    Terminal Çıktısı      │
          │                          │
          │  Spinner animasyonu      │
          │  İlerleme çubuğu        │
          │  Renkli çıktı (Rainbow) │
          │  OSLog yapısal log       │
          └──────────────────────────┘
```

### Katman Açıklamaları

| Katman | Açıklama |
|--------|----------|
| **CLI** | 7 alt komut sunan giriş noktası; argüman ayrıştırma ve iş akışı yönetimi |
| **İçerik Girdi** | Web'den (SwiftSoup ile HTML parse) ve yerel dosyalardan makale toplama, `~/.yazman/corpus/` altında JSON önbellek |
| **Denetim Motoru** | Markdown'dan paragraf çıkarma, RAG bağlamı oluşturma, LLM'e akış (streaming) sorguları gönderme |
| **RAG Boru Hattı** | Actor tabanlı VectorStore: metin parçalama → embedding üretimi → SIMD hızlandırmalı cosine similarity arama |
| **Ollama** | Yerel LLM sunucusu; Lifecycle bileşeni Homebrew servisleri ile otomatik başlatma/durdurma ve sinyal yönetimi sağlar |
| **Terminal Çıktısı** | Braille spinner, kelime kelime açılma efekti, ilerleme çubuğu, renkli biçimlendirme ve yapısal loglama |

### Veri Akışı

1. **Corpus**: Türkçe teknik makaleler parçalara (chunk) bölünür ve `nomic-embed-text` ile embedding vektörleri oluşturulur
2. **RAG**: Denetlenen makaleye en benzer parçalar cosine similarity ile bulunur
3. **LLM**: Referans metinlerle birlikte `gemma3:4b` modeline gönderilir ve Türkçe yazım önerileri üretilir

Tüm işlem yerel makinenizde gerçekleşir — veri dışarıya çıkmaz.

## Komutlar

| Komut | Açıklama |
|-------|----------|
| `yazman add <dosyalar...>` | Yerel dosyaları corpus'a ekler |
| `yazman scrape [url'ler...]` | Web'den makale tarar ve indeksler |
| `yazman check <makale>` | Paragraf paragraf dil denetimi yapar |
| `yazman review <makale>` | Bütünsel makale incelemesi yapar |
| `yazman improve <makale>` | RAG tabanlı iyileştirme önerileri sunar |
| `yazman search <sorgu>` | Corpus'ta anlamsal arama yapar |
| `yazman stats` | Corpus ve model istatistiklerini gösterir |

## Teknik Ayrıntılar

| Bileşen | Teknoloji |
|---------|-----------|
| Dil | Swift 6.0, macOS 13+ |
| CLI Çatısı | [swift-argument-parser](https://github.com/apple/swift-argument-parser) |
| LLM İstemcisi | [ollama-swift](https://github.com/mattt/ollama-swift) |
| HTML Ayrıştırma | [SwiftSoup](https://github.com/scinfu/SwiftSoup) |
| Terminal Renklendirme | [Rainbow](https://github.com/onevcat/Rainbow) |
| Metin Modeli | `gemma3:4b` |
| Embedding Modeli | `nomic-embed-text` |
| Vektör Deposu | Actor tabanlı, cosine similarity, JSON disk |
| Parçalama | 500 karakter, 100 karakter örtüşme |
| Sürekli Entegrasyon | GitHub Actions (derleme + test + SwiftLint) |
| Testler | 70 birim testi |

## Geliştirme

```bash
# Derleme
swift build

# Testleri çalıştır
swift test

# Lint kontrolü
swiftlint --strict
```

## Katkıda Bulunma

Katkılarınızı bekliyoruz! Ayrıntılar için [CONTRIBUTING.md](CONTRIBUTING.md) rehberine göz atın.

Kısaca: bir issue açın, fork'layın, değişikliklerinizi yapın, `swift test` ve `swiftlint --strict` ile doğrulayın, PR gönderin.

## Lisans

[MIT](LICENSE)
