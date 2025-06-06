# AnyDocGen

anysrc内の資料をtex内にtexで資料化・論文化するツール

## プロジェクト構造

```
anytexgen/
├── anysrc/                 # ソース資料
├── prompts/                # プロンプトテンプレート
├── refs/                   # 参考資料
│   ├── build/              # OCR処理済みMarkdown
│   └── materials/          # 元のPDFファイル
├── tex/                    # TeXプロジェクト
│   ├── jcmsi/temp/         # JCMSI論文
│   │   ├── fig/            # 画像データ
│   │   ├── sections/       # 各章のtex
│   │   └── template.tex    # メインのtex
│   ├── seminar/temp/       # セミナー発表
│   │   ├── fig/            # 画像データ
│   │   ├── sections/       # 各章のtex
│   │   └── template_v1.0.tex
│   └── sice/temp/          # SICE論文
│       ├── Fig/            # 画像データ
│       └── SICE_FES25.tex  # メインのtex
└── utils/                  # 統合されたユーティリティスクリプト
    ├── compile_tex.sh      # TeXコンパイル（PNG->EPS変換付き）
    ├── auto_compile_tex.sh # 自動監視コンパイル
    └── convert_png_to_eps.sh # PNG->EPS変換
```

## 使用方法

### 推奨：レポジトリルートからのコンパイル

レポジトリルートディレクトリから、各プロジェクトを簡単にコンパイルできます：

```bash
# 基本コンパイル
./compile.sh <project_path> [--clean]

# 自動監視コンパイル（ファイル変更を検出して自動実行）
./auto_compile.sh <project_path> [--clean]
```

#### プロジェクト指定方法

```bash
# JCMSI論文をコンパイル
./compile.sh tex/jcmsi/temp

# セミナー発表をコンパイル（中間ファイル削除付き）
./compile.sh tex/seminar/temp --clean

# SICE論文を自動監視コンパイル
./auto_compile.sh tex/sice/temp

# ヘルプを表示
./compile.sh --help
./auto_compile.sh --help
```

#### 各プロジェクトの自動設定

スクリプトは各プロジェクトの設定を自動検出します：

- **tex/jcmsi/temp**: `template.tex` (fullモード) + `fig/` ディレクトリ
- **tex/seminar/temp**: `template_v1.0.tex` (simpleモード) + `fig/` ディレクトリ  
- **tex/sice/temp**: `SICE_FES25.tex` (simpleモード) + `Fig/` ディレクトリ

### 高度な使用方法：utilsスクリプトの直接実行

より細かい制御が必要な場合は、utilsスクリプトを直接使用できます：

```bash
# 基本的な使用方法
utils/compile_tex.sh <tex_file> [directory] [type] [--clean] [fig_dirs...]

# 例：JCMSIプロジェクトをフルコンパイル（参考文献付き）
utils/compile_tex.sh template.tex tex/jcmsi/temp full --clean fig

# 例：SICEプロジェクトをシンプルコンパイル
utils/compile_tex.sh SICE_FES25.tex tex/sice/temp simple Fig

# 自動監視コンパイル
utils/auto_compile_tex.sh template.tex tex/seminar/temp simple fig

# PNG->EPS変換のみ
utils/convert_png_to_eps.sh [options] [directories...]
utils/convert_png_to_eps.sh -f tex/jcmsi/temp/fig    # 強制上書き
utils/convert_png_to_eps.sh -r tex/                  # 再帰的に全ディレクトリ処理
```

### 従来の方法：各プロジェクト内でのコンパイル

各プロジェクトのtempディレクトリ内でも実行可能（非推奨）：

```bash
cd tex/jcmsi/temp
../../../utils/compile_tex.sh template.tex . full fig
```

### コンパイルタイプ

- **simple**: `platex + dvipdfmx`（通常の論文）
- **full**: `platex + pbibtex + platex + platex + dvipdfmx`（参考文献付き）

### 自動PNG->EPS変換

コンパイル時に自動的に：
- 指定された図ディレクトリ内のPNGファイルをEPSに変換
- PNGファイルがEPSファイルより新しい場合のみ変換を実行
- ImageMagickが必要（未インストールの場合は警告のみ）

### 必要なソフトウェア

- **TeX環境**: platex, dvipdfmx, pbibtex
- **画像変換**: ImageMagick（convertコマンド）
- **自動監視**: inotify-tools（inotifywaitコマンド）

```bash
# Ubuntu/Debianの場合
sudo apt install texlive-lang-japanese imagemagick inotify-tools

# macOSの場合
brew install imagemagick fswatch
```

## 各プロジェクトの特徴

### JCMSI
- フルコンパイル対応（参考文献処理）
- 図ディレクトリ: `fig/`

### Seminar
- シンプルコンパイル
- 図ディレクトリ: `fig/`

### SICE
- シンプルコンパイル
- 図ディレクトリ: `Fig/`（大文字のF）

## トラブルシューティング

### コンパイルエラー
- エラーが発生してもスクリプトは続行します
- `.log`ファイルでエラー詳細を確認してください

### 画像変換エラー
- ImageMagickがインストールされているか確認
- PNGファイルが破損していないか確認

### 自動監視が動作しない
- inotify-toolsがインストールされているか確認
- ファイルシステムがinotifyをサポートしているか確認