# デフォルトタスク: 利用可能なコマンドを一覧表示
default:
    @just --list

# Brewfile から依存パッケージをインストール
install:
    brew bundle

# prek を全ファイルに対して実行
lint:
    prek run -a
