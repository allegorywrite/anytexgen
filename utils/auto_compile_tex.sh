#!/bin/bash

# 汎用TeXファイル自動監視・コンパイルスクリプト（PNG->EPS変換付き）
# 使用方法: ./auto_compile_tex.sh <tex_file> [directory] [type] [--clean] [fig_dirs...]
# type: simple (platex + dvipdfmx) または full (platex + pbibtex + platex + platex + dvipdfmx)

show_help() {
    echo "使用方法: $0 <tex_file> [directory] [type] [--clean] [fig_dirs...]"
    echo "  tex_file: 監視するTeXファイル名"
    echo "  directory: TeXファイルがあるディレクトリ（省略時は現在のディレクトリ）"
    echo "  type: simple または full（省略時はsimple）"
    echo "    simple: platex + dvipdfmx"
    echo "    full: platex + pbibtex + platex + platex + dvipdfmx"
    echo "  --clean: コンパイル後に中間ファイルを削除"
    echo "  fig_dirs: PNG->EPS変換を行うディレクトリ（複数指定可能）"
}

if [ $# -lt 1 ]; then
    show_help
    exit 1
fi

# 引数解析
TEX_FILE="$1"
DIR="${2:-.}"
TYPE="${3:-simple}"
CLEAN=false
shift 3  # 最初の3つの引数を削除

# --cleanオプションの確認
ARGS=()
for arg in "$@"; do
    if [ "$arg" = "--clean" ]; then
        CLEAN=true
    else
        ARGS+=("$arg")
    fi
done

FIG_DIRS=("${ARGS[@]}")  # 残りの引数を図ディレクトリとして取得

# ディレクトリに移動
cd "$DIR" || { echo "エラー: ディレクトリ '$DIR' に移動できません"; exit 1; }

# TeXファイルの存在確認
if [ ! -f "$TEX_FILE" ]; then
    echo "エラー: TeXファイル '$TEX_FILE' が見つかりません"
    exit 1
fi

# inotifywaitの存在確認
if ! command -v inotifywait &> /dev/null; then
    echo "エラー: inotifywaitが見つかりません。inotify-toolsをインストールしてください。"
    exit 1
fi

# PNG->EPS変換関数
convert_png_to_eps() {
    local fig_dir="$1"
    if [ ! -d "$fig_dir" ]; then
        return 0
    fi
    
    # ImageMagickの存在確認
    if ! command -v convert &> /dev/null; then
        return 0
    fi
    
    local original_dir=$(pwd)
    cd "$fig_dir" || return 1
    
    # PNGファイルが存在するかチェック
    if ! ls *.png 1> /dev/null 2>&1; then
        cd "$original_dir"
        return 0
    fi
    
    local converted_count=0
    for png_file in *.png; do
        base_name="${png_file%.png}"
        eps_file="${base_name}.eps"
        
        # PNGがEPSより新しい場合のみ変換
        if [ ! -f "$eps_file" ] || [ "$png_file" -nt "$eps_file" ]; then
            echo "画像変換: $png_file -> $eps_file"
            convert "$png_file" "$eps_file" && ((converted_count++))
        fi
    done
    
    if [ $converted_count -gt 0 ]; then
        echo "$fig_dir: $converted_count 件の画像を変換しました"
    fi
    cd "$original_dir"
}

echo "自動コンパイルを開始します。$TEX_FILE の変更を監視しています... (タイプ: $TYPE)"
echo "終了するには Ctrl+C を押してください。"

# コンパイル関数
compile_tex() {
    echo "コンパイルを実行します..."
    
    # PNG->EPS変換を実行
    if [ ${#FIG_DIRS[@]} -gt 0 ]; then
        for fig_dir in "${FIG_DIRS[@]}"; do
            convert_png_to_eps "$fig_dir"
        done
    fi
    
    if [ "$TYPE" = "full" ]; then
        platex -interaction=nonstopmode "$TEX_FILE" || echo "1回目のplatexでエラーが発生しましたが、処理を続行します。"
        pbibtex "${TEX_FILE%.tex}" || echo "pbibtexでエラーが発生しましたが、処理を続行します。"
        platex -interaction=nonstopmode "$TEX_FILE" || echo "2回目のplatexでエラーが発生しましたが、処理を続行します。"
        platex -interaction=nonstopmode "$TEX_FILE" || echo "3回目のplatexでエラーが発生しましたが、処理を続行します。"
    else
        platex -interaction=nonstopmode "$TEX_FILE" || echo "platexでエラーが発生しましたが、処理を続行します。"
    fi
    dvipdfmx "${TEX_FILE%.tex}.dvi" || echo "dvipdfmxでエラーが発生しましたが、処理を続行します。"
    
    # クリーンアップ処理
    if [ "$CLEAN" = true ]; then
        rm -f *.aux *.bbl *.blg *.log *.dvi *.out *.toc *.lof *.lot *.fls *.fdb_latexmk *.synctex.gz
    fi
    
    echo "コンパイル完了: ${TEX_FILE%.tex}.pdf が生成されました。"
}

# 初回コンパイル
echo "初回コンパイルを実行します..."
compile_tex

# 監視対象ディレクトリの準備
WATCH_DIRS=("$TEX_FILE")
if [ -d "sections" ]; then
    WATCH_DIRS+=("sections")
fi

# 図ディレクトリも監視対象に追加
for fig_dir in "${FIG_DIRS[@]}"; do
    if [ -d "$fig_dir" ]; then
        WATCH_DIRS+=("$fig_dir")
    fi
done

# 変更を監視して自動コンパイル
while true; do
    inotifywait -e modify -r "${WATCH_DIRS[@]}" 2>/dev/null
    echo "ファイルの変更を検出しました。"
    compile_tex
done