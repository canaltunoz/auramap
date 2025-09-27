Bu dokuman, en iyi uygulamalara (best practices) gore uctan uca adim adim yol haritasi icerir. 0) Mimari Ozet

- Mobil (Flutter): feature-first yapi, guvenli oturum, offline-dostu.
- API (NestJS + Fastify): modul bazli mimari (Auth, User, Chart, Report, Purchase), DTO/Validation, RBAC.
- DB: PostgreSQL + Prisma (onerilir). Cache/Queue: Redis + BullMQ.
- Gozlemlenebilirlik: Sentry, Prometheus; Odeme: AppStore/Play IAP; Depolama: S3.
- CI/CD: GitHub Actions + Fastlane; Dagitim: Docker tabanli.

1. On Kosullar (Toolchain)
   Bilesen Notlar
   Flutter 3.x, flutter_lints, dart_code_metrics, (opsiyonel) melos
   Node/NestJS Node 20 LTS, Nest 10+, Fastify adapter
   DB PostgreSQL 14+, Prisma 5.x
   Diger Redis, Docker/Compose, GitHub Actions, Fastlane, Sentry
2. Repo Stratejisi

- Baslangic icin 2 repo: human-design-backend/ ve human-design-app/.
- Paylasilacak ortak paketler icin daha sonra monorepo (melos) dusunulebilir.

3. Git ve Kalite Kurallari

- Conventional Commits + semantic versioning, trunk-based gelistirme.
- Pre-commit: lint + test. Flutter: analyze/test; Nest: eslint + jest.

4. Backend (NestJS) – Iskelet

- Moduller: auth, users, charts, reports, purchases, webhooks, common.
- Fastify, Helmet, RateLimit, CORS, Swagger, ValidationPipe (whitelist + transform).
- Prisma ile User, Chart (isim alanli), Purchase tablolarini kur.
  Auth ve Guvenlik (Ozet)
- JWT: access (kisa), refresh (uzun); refresh token DB’de hash’lenir.
- RolesGuard ile RBAC. PII maskeli loglama. Rate limit + Helmet basliklari.
  Rapor Uretimi
- BullMQ kuyru■u: report:generate; worker HTML→PDF (Puppeteer) veya PDFKit.
- S3’e yukle, pre-signed link don.
  Odeme ve Makbuz Dogrulama
- Hizi icin RevenueCat ile basla; ileri asamada AppStore SN v2 + Play Subs API.
- Webhook’lar ile purchase durumunu (active/canceled/refunded) senkronize et.

5. Flutter – Iskelet ve Paketler

- State: Riverpod (veya Bloc). HTTP: dio (+interceptor). JSON: freezed + json_serializable.
- Router: go_router; Secure: flutter_secure_storage; Crash: sentry_flutter; Push: firebase_messaging.
- Feature-first klasor yapisi ve temiz ayrisim (data/domain/presentation).
  Ag ve Oturum
- Access token hafizada, refresh token SecureStorage; 401’de 1 kez refresh dene ve istegi tekrar et.
- Hata/bos durum iskeletleri, offline cache (son basarili yanit).

6. Free vs Pro Mantigi
   Alan Free Pro
   Chart & Temel Bodygraph + Tip/Strateji/Authority ozet Merkez/kanal/gate detaylari
   Insights Gunluk 1 mini-insight Limitsiz + kisisellestirilmis push
   Raporlar - Kisisel Derin Rapor (PDF), Partner/Child (ileri)
   Paylasim Temel kart PDF indirme, gelismis sablonlar
7. Fiyat Ornekleri (ornek/realistik)
   Pazar Aylik Yillik (~%35 indirim)
   TR (TRY) TRY 149 / ay TRY 1,190 / yil
   Global (USD) $7.99 / ay $59.99 / yil
   Not: Fiyatlar ornektir; magaza kesintileri, vergi ve A/B testlerine gore degisebilir.
8. Guvenlik ve Gizlilik

- Mobil: SecureStorage, (ops) TLS pinning; Backend: Helmet, rate-limit, input validation.
- KVKK/GDPR: acik riza, tibbi/psikolojik tavsiye degildir beyanlari, min. veri saklama.

9. CI/CD

- Backend: lint + test + docker build/push + deploy + migrate + smoke test.
- Flutter: analyze + test + Fastlane ile imzali derleme ve TestFlight/Closed Track dagitim.

10. Production Hazirlik (Checklist)

- Health/readiness endpoints
- Rate-limit ve CORS matrisleri
- Sentry entegre, PII maskesi
- DB yedekleme ve rollback plani
- Makbuz dogrulama fail-safe (timeout, retry, idempotency)
- Store privacy formlari ve 3P SDK bildirimleri

11. Veri Akisi (Ozet)
1. Login → tokens | 2) Chart olustur (isim + dogum verisi) | 3) Free/Pro icerik listesi | 4) Satin alma + webhook
   dogrulama | 5) Pro icerik acilir | 6) Rapor queue → PDF → S3 link.
1. Adim Adim Yol Haritasi

1) Domain ve Prisma semasi
2) Nest iskeleti (Config, Swagger, Helmet, RateLimit, Validation)
3) Auth: login/refresh, RBAC, testler
4) Charts: DTO + hesaplama entegrasyonu + test
5) Paywall/IAP: makbuz dogrulama (proxy veya native), webhook
6) Reports: Queue + worker + PDF + S3
7) Flutter iskeleti: Riverpod + Dio + Router + SecureStorage
8) Auth akisi + interceptor
9) Chart formu (Isim alani dahil) + sonuc ekranlari
10) Paywall + Free/Pro kilitleme
11) Rapor indirme akisi
12) Push + Analytics
13) Sentry + Observability
14) CI/CD boru hatti
15) Prod checklist ve kapali beta
