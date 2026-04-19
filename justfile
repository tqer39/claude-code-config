# デフォルトタスク: 利用可能なコマンドを一覧表示
default:
    @just --list

# Brewfile から依存パッケージをインストール
install:
    brew bundle

# 環境セットアップ: 依存インストール + Git フックのインストール
setup: install
    prek install -t pre-commit -t commit-msg

# prek を全ファイルに対して実行
lint:
    prek run --all-files
