#!/usr/bin/env bash
# 把 logo 與 CryptoJS 注入 src.html 的佔位符，組裝出單一自包含 index.html
set -euo pipefail
cd "$(dirname "$0")"
LOGO="${LOGO:-/root/mastodon_svg/logo-symbol-wordmark.svg}"
python3 - "$LOGO" <<'PY'
import sys
from pathlib import Path
logo_path = sys.argv[1]
src = Path('src.html').read_text()
lib = Path('assets/crypto-js.min.js').read_text()
logo = Path(logo_path).read_text().strip()
src = src.replace('<!--LOGO-->', logo)
src = src.replace('<!--CRYPTOJS_INLINE-->', '<script>\n'+lib+'\n</script>')
Path('index.html').write_text(src)
print('index.html 組裝完成:', len(src), 'bytes')
PY
