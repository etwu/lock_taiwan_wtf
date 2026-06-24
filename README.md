# lock.taiwan.wtf — 嘟文加密小工具

在你自己的瀏覽器，用密碼把文字加密成一段可貼到任何地方（包括 Mastodon 嘟文）的字串；對方有密碼就能解開。**加密、解密完全在用戶端進行，密碼與內容不會傳到任何伺服器。**

由 [台灣幹網 taiwan.wtf](https://taiwan.wtf) 提供。線上版：**https://lock.taiwan.wtf**

![AES-256-CBC](https://img.shields.io/badge/cipher-AES--256--CBC-6364FF)
![client-side](https://img.shields.io/badge/100%25-client--side-1f9d57)
![no-dependencies](https://img.shields.io/badge/runtime%20deps-none-blue)

---

## 特色

- **純前端、零網路請求**：可開瀏覽器開發者工具的「網路」分頁自行確認，按下加密時不會發出任何請求。
- **可離線使用**：整個工具是單一 `index.html`（連 CryptoJS 都內嵌、不走 CDN），存到本機用 `file://` 開即可，完全不需連網。
- **標準格式、不綁定本工具**：採用 AES-256-CBC，輸出與 **OpenSSL / CryptoJS 相容**，你也能用其他標準工具解開（見下方）。
- **嘟文模式**：自動檢查加密後長度是否在發文上限（1000 字）內，並附上 `#encrypted-toots` 標籤，方便未來的自動解密工具辨識。
- **三種解密輸入**：純密文、整則嘟文文字、或公開嘟文網址（自動抓取）。
- 正體中文介面、深色模式。

---

## 加密規格

| 項目 | 內容 |
|---|---|
| 演算法 | AES-256-CBC（PKCS#7 padding） |
| 封裝格式 | OpenSSL `Salted__` 格式，Base64 編碼（密文一律以 `U2FsdGVkX1` 開頭） |
| 金鑰導出 | EVP_BytesToKey（MD5，1 次迭代）— 即 CryptoJS `AES.encrypt(text, passphrase)` 預設 |
| Salt | 每次隨機 8 bytes |
| 函式庫 | [CryptoJS 4.2.0](https://github.com/brix/crypto-js)（內嵌） |

### ⚠️ 安全性說明

為了**與市面上常見的線上 AES 工具互通**，本工具刻意沿用 CryptoJS 預設的金鑰導出方式（MD5、單次迭代），這在現代標準下偏弱。**安全強度主要取決於密碼**——請務必使用夠長、夠隨機的密碼。這個工具適合「把訊息做簡單加密、避免被一眼看光」的情境，不適合用於對抗有資源的針對性破解。

---

## 用其他標準工具解開（證明不被綁定）

加密結果（例如 `U2FsdGVkX1...`）可被任何相容工具解開：

**OpenSSL**（注意 OpenSSL 3.x 要用 `-md md5`）：
```bash
echo 'U2FsdGVkX1...' | openssl enc -d -aes-256-cbc -md md5 -a -A -pass pass:你的密碼
```

**CyberChef**：`From Base64` →（或直接用）`AES Decrypt`，Key 選「Passphrase」、KDF 選 OpenSSL/MD5。

**任何 CryptoJS 系線上 AES 工具**：貼上密文 + 密碼即可。

反過來，這些工具加密的字串本工具也能解。

---

## 嘟文加密協定（`#encrypted-toots`）

為了讓未來的自動解密工具（例如 Mastodon 客戶端外掛、[Phanpy fork](https://fly.taiwan.wtf) 等）能辨識並處理加密嘟文，定義以下簡單協定：

1. **辨識標籤**：嘟文含 `#encrypted-toots` 標籤即視為加密嘟文。
2. **密文擷取**：用正規式 `U2FsdGVkX1[A-Za-z0-9+/=]+` 從嘟文內文抓出密文（CryptoJS/OpenSSL 的 `Salted__` Base64 自帶此魔術前綴，不會與其他文字混淆）。
3. **版面**（本工具產生）：
   ```
   〔可選：用戶提示行〕
   U2FsdGVkX1…（密文，獨立一行）
   〔可選：🔒這是加密訊息，詳見 lock.taiwan.wtf〕
   #encrypted-toots
   ```
4. **解密**：取得密文後，向用戶索取密碼，在**用戶端**用上述 AES-256-CBC 規格解密。**切勿把密碼或密文送到伺服器。**

> 解密工具必須是用戶端執行（瀏覽器／本機 App）。任何「把密文傳給伺服器代解」的設計都違背本工具的安全前提。

---

## 部署

單一靜態檔，適合任何靜態主機。本專案部署於 **Cloudflare Pages**（`lock.taiwan.wtf`），推送到 `main` 分支即自動部署。

本機 / 離線使用：直接打開 `index.html` 即可。

---

## 開發

`index.html` 是組裝後的成品。原始碼分離為：

- `src.html` — HTML / CSS / 應用邏輯（含 `<!--LOGO-->`、`<!--CRYPTOJS_INLINE-->` 佔位符）
- `assets/crypto-js.min.js` — 內嵌的 CryptoJS（CDN 下載，SHA256 見 git 紀錄）
- 組裝：把 logo 與 CryptoJS 注入 `src.html` 的佔位符，輸出 `index.html`

---

## 授權

工具程式碼：MIT。CryptoJS 為其原作者之 MIT 授權。
