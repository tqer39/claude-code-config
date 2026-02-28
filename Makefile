.PHONY: bootstrap

# Homebrew をインストールし、依存パッケージをセットアップ
bootstrap:
	@command -v brew >/dev/null 2>&1 || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	@just install
