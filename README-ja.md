# agents-md-generator

[English](README.md)

空リポジトリをcloneしたときに `AGENTS.md`（と `CLAUDE.md` シンボリンク）を自動生成するgit hookです。

> ブログ記事: [AGENTS.mdを自動で育てる仕組みを作った](https://nyosegawa.github.io/posts/agents-md-generator/)

## なぜ作ったか

新しいリポジトリを作るたびに `AGENTS.md` を手で書くのは面倒です。[AGENTS.md](https://agents.md/) はCursor、Zed、Codex、Gemini CLI、GitHub Copilotなど主要なCoding Agentが対応する標準フォーマットで、Claude Codeは `CLAUDE.md` を読みます。両方を毎回セットアップするのは地味につらい。

このhookは種を自動で蒔きます。あとはプロジェクトと一緒に育てていくだけです。

## セットアップ

```bash
mkdir -p ~/.git-templates/hooks
cp post-checkout ~/.git-templates/hooks/post-checkout
chmod +x ~/.git-templates/hooks/post-checkout
git config --global init.templateDir ~/.git-templates
```

## 使い方

```bash
# 普通にcloneするだけ
git clone git@github.com:you/new-repo.git

# AGENTS.md と CLAUDE.md（シンボリンク）が生成されている
ls new-repo/
# AGENTS.md  CLAUDE.md -> AGENTS.md

# ghqでも動く
ghq get you/new-repo
```

## 仕組み

`post-checkout` hookが `git clone` の直後に実行され:

1. リポジトリが空かどうかチェック（`.git`を除いて3項目未満）
2. `AGENTS.md` がすでにあればスキップ
3. 組み込みテンプレートから `AGENTS.md` を生成
4. `CLAUDE.md` を `AGENTS.md` へのシンボリンクとして作成

## テンプレートの設計思想

生成される `AGENTS.md` は完成品ではなく足場です。

- **20〜30行の指示量バジェット** — 指示が多すぎるとLLMの性能が下がる。少なく保つ
- **後方互換性はデフォルトで不要** — 大胆なリファクタリングを優先
- **プレースホルダーセクション** — プロジェクトの成長に合わせて埋めていき、埋めたらプレースホルダーを消す
- **Maintenance Notesは永続** — `AGENTS.md` は設定ファイルではなく生きたドキュメントであることのリマインダー
- **HTMLコメントによるセクション保護** — エージェントによるファイル構造の意図しない変更を防止

## カスタマイズ

テンプレートの内容は `post-checkout` 内の `cat > AGENTS.md << 'EOF'` 〜 `EOF` の間を編集してください。

空リポジトリ判定の閾値を変更:

```bash
if [ $TOTAL -lt 3 ]; then  # この数値を調整
```

## 対応ツール

| ツール | 読むファイル |
|--------|-------------|
| Cursor, Zed, OpenCode, Codex, Gemini CLI, ... | `AGENTS.md` |
| Claude Code | `CLAUDE.md`（シンボリンク → `AGENTS.md`） |

## ライセンス

[MIT](LICENSE)
