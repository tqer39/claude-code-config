# plugins/terraform プラグインの削除

## 背景
`plugins/terraform` は tf-review と tf-security の2つのスキルを含むが、いずれも TODO コメントのみで未実装。今後も実装予定がないため、マーケットプレイスから削除する。

## 変更対象

| 操作 | 対象 | 詳細 |
|------|------|------|
| 削除 | `plugins/terraform/` | ディレクトリ全体（plugin.json, SKILL.md x2） |
| 編集 | `.claude-plugin/marketplace.json` | plugins 配列から terraform エントリを除去 |
| 編集 | `README.md` | terraform セクションを除去 |

## 影響範囲
- 他プラグインからの依存: なし
- 機能的影響: なし（未実装のため）

## 検証
1. marketplace.json の JSON 構文が正しいことを確認
2. `grep -r "terraform"` で残存参照がないことを確認
3. marketplace-lint があれば実行
