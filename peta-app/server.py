#!/usr/bin/env python3
"""Server kecil untuk peta (Python standar, tanpa pip install).

- Menyajikan index.html.
- GET /api/layers       -> daftar layer (tanpa API key).
- GET /api/layer/<id>   -> diteruskan ke API Gateway: GET {gateway_url}/api/v1/gateway/data/<path>
                           dengan header `apikey` milik layer tsb.

API key hanya ada di server (config.json), tidak pernah dikirim ke browser.

Jalankan:  python3 server.py            (lalu buka port 8766 di browser)
"""
import argparse
import json
import pathlib
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HERE = pathlib.Path(__file__).resolve().parent


class Handler(BaseHTTPRequestHandler):
    config: dict = {}

    def _send(self, status: int, body: bytes, content_type: str) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _json(self, status: int, data: dict) -> None:
        self._send(status, json.dumps(data, ensure_ascii=False).encode("utf-8"), "application/json; charset=utf-8")

    def do_GET(self) -> None:
        if self.path in ("/", "/index.html"):
            self._send(200, (HERE / "index.html").read_bytes(), "text/html; charset=utf-8")
        elif self.path == "/api/layers":
            self._json(200, {"layers": [{k: l.get(k, "") for k in ("id", "label", "description")} for l in self.config["layers"]]})
        elif self.path.startswith("/api/layer/"):
            layer_id = self.path.removeprefix("/api/layer/")
            layer = next((l for l in self.config["layers"] if l["id"] == layer_id), None)
            if layer is None:
                self._json(404, {"error": f"Layer '{layer_id}' tidak ada di config"})
                return
            request = urllib.request.Request(
                f"{self.config['gateway_url']}/api/v1/gateway/data/{layer['path']}", headers={"apikey": layer["apikey"]}
            )
            try:
                with urllib.request.urlopen(request, timeout=120) as response:
                    self._json(200, json.loads(response.read())["data"])
            except urllib.error.HTTPError as exc:
                self._json(exc.code, {"error": f"Gateway menolak ({exc.code}): {exc.read().decode('utf-8', 'replace')[:300]}"})
            except (urllib.error.URLError, TimeoutError) as exc:
                self._json(502, {"error": f"Gateway tidak bisa dihubungi: {exc}"})
        else:
            self._json(404, {"error": "Not found"})


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=8766)
    parser.add_argument("--config", default=str(HERE / "config.json"))
    args = parser.parse_args()
    config = json.loads(pathlib.Path(args.config).read_text(encoding="utf-8"))
    config["gateway_url"] = config["gateway_url"].rstrip("/")
    Handler.config = config
    print(f"Peta: http://localhost:{args.port}  ({len(config['layers'])} layer)")
    ThreadingHTTPServer(("0.0.0.0", args.port), Handler).serve_forever()


if __name__ == "__main__":
    main()
