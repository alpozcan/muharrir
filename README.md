<p align="center">
  <h1 align="center">Muharrir</h1>
  <p align="center">
    <em>Türkçe teknik makale yazım denetleyicisi — yerel LLM + RAG ile.</em>
  </p>
  <p align="center">
    <a href="https://github.com/alpozcan/muharrir/releases"><img src="https://img.shields.io/github/v/release/alpozcan/muharrir?style=flat-square&label=version" alt="Release"></a>
    <a href="https://github.com/apple/swift-package-manager"><img src="https://img.shields.io/badge/SPM-compatible-orange?style=flat-square" alt="Swift Package Manager"></a>
    <a href="https://github.com/yonaskolb/Mint"><img src="https://img.shields.io/badge/Mint-compatible-brightgreen?style=flat-square" alt="Mint"></a>
    <a href="https://github.com/alpozcan/homebrew-muharrir"><img src="https://img.shields.io/badge/Homebrew-tap-yellow?style=flat-square&logo=homebrew" alt="Homebrew"></a>
    <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-6.0+-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift 6.0+"></a>
    <a href="https://github.com/alpozcan/muharrir/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/alpozcan/muharrir/ci.yml?style=flat-square&label=CI" alt="CI"></a>
    <a href="https://github.com/alpozcan/muharrir/blob/main/LICENSE"><img src="https://img.shields.io/github/license/alpozcan/muharrir?style=flat-square" alt="License"></a>
  </p>
</p>

---

Muharrir, Türkçe teknik makalelerin dilini ve ifade biçimini yerel LLM (Ollama) ve RAG (Retrieval-Augmented Generation) kullanarak denetler ve iyileştirme önerileri sunar. Verileriniz makinenizden çıkmaz.

## Kurulum

### Homebrew

```bash
brew tap alpozcan/muharrir
brew install muharrir
```

### Mint

```bash
mint install alpozcan/muharrir
```

### Swift Package Manager (kaynak koddan derleme)

```bash
git clone https://github.com/alpozcan/muharrir.git
cd muharrir
swift build -c release
cp .build/release/muharrir /usr/local/bin/
```

### Gereksinimler

Muharrir, [Ollama](https://ollama.ai)'nın yerel olarak çalışmasını gerektirir:

```bash
brew install ollama
brew services start ollama
ollama pull gemma3:4b            # Metin üretimi
ollama pull nomic-embed-text     # Embedding'ler
```

## Kullanim

### Corpus oluşturma

Makaleleri corpus'a ekleyerek RAG bağlamı oluşturun:

```bash
# Yerel markdown dosyaları ekle
muharrir add makale.md diger-makale.md

# Web'den Türkçe teknik makaleleri tara
muharrir scrape https://example.com/swift-makale

# Seed URL'lerden otomatik keşif
muharrir scrape --discover
```

### Dil denetimi

```bash
# Paragraf paragraf dil kontrolü (RAG destekli)
muharrir check makale.md

# RAG olmadan kontrol
muharrir check makale.md --no-rag

# Bütünsel makale incelemesi
muharrir review makale.md

# Somut kelime/ifade iyileştirme önerileri
muharrir improve makale.md
```

### Arama ve istatistik

```bash
# Corpus'ta anlamsal arama
muharrir search "Swift macro kullanımı"

# Sonuç sayısını belirle
muharrir search "async defer" -n 10

# Corpus ve model istatistikleri
muharrir stats
```

## Nasil Calisiyor?

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────┐
│  Makaleler  │────▶│  Embedding Model │────▶│ Vector Store│
│  (.md)      │     │ (nomic-embed)    │     │ (JSON disk) │
└─────────────┘     └──────────────────┘     └──────┬──────┘
                                                    │
┌─────────────┐     ┌──────────────────┐            │ RAG
│   Analiz    │ ◀───│    LLM Model     │◀───────────┘
│   Çıktısı   │     │  (gemma3:4b)     │
└─────────────┘     └──────────────────┘
```

1. **Corpus**: Türkçe teknik makaleler chunk'lara bölünür ve `nomic-embed-text` ile embedding'leri oluşturulur
2. **RAG**: Kontrol edilen makaleye en benzer chunk'lar cosine similarity ile bulunur
3. **LLM**: Referans metinlerle birlikte `gemma3:4b` modeline gönderilir ve Türkçe yazım önerileri üretilir

Tüm işlem yerel makinenizde gerçekleşir — veri dışarı çıkmaz.

## Teknik Detaylar

| Bileşen | Teknoloji |
|---------|-----------|
| Dil | Swift 6.0, macOS 13+ |
| CLI Framework | [swift-argument-parser](https://github.com/apple/swift-argument-parser) |
| LLM İstemci | [ollama-swift](https://github.com/mattt/ollama-swift) |
| HTML Ayrıştırma | [SwiftSoup](https://github.com/scinfu/SwiftSoup) |
| Terminal Renkleri | [Rainbow](https://github.com/onevcat/Rainbow) |
| Metin Modeli | `gemma3:4b` |
| Embedding Modeli | `nomic-embed-text` |
| Vector Store | Actor-tabanlı, cosine similarity, JSON disk |
| Chunking | 500 karakter, 100 karakter overlap |
| CI/CD | GitHub Actions (build + test + SwiftLint) |
| Testler | 45 birim testi |

## Komutlar

| Komut | Açıklama |
|-------|----------|
| `muharrir add <dosyalar...>` | Yerel dosyaları corpus'a ekle |
| `muharrir scrape [url'ler...]` | Web'den makale tara ve indeksle |
| `muharrir check <makale>` | Paragraf paragraf dil denetimi |
| `muharrir review <makale>` | Bütünsel makale incelemesi |
| `muharrir improve <makale>` | RAG tabanlı iyileştirme önerileri |
| `muharrir search <sorgu>` | Corpus'ta anlamsal arama |
| `muharrir stats` | Corpus ve model istatistikleri |

## Lisans

MIT

## Geliştirme

```bash
# Derleme
swift build

# Testleri çalıştır
swift test

# Lint kontrolü
swiftlint --strict
```

## Katkida Bulunma

Pull request'ler memnuniyetle karşılanır. Lütfen önce bir issue açarak değişikliği tartışın. CI pipeline build, test ve lint kontrollerini otomatik çalıştırır.
