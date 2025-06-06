#!/bin/bash

# 汎用TeXコンパイルスクリプト（PNG->EPS変換付き）
# 使用方法: ./compile_tex.sh <tex_file> [directory] [type] [--clean] [fig_dirs...]
# type: simple (platex + dvipdfmx) または full (platex + pbibtex + platex + platex + dvipdfmx)

show_help() {
    echo "使用方法: $0 <tex_file> [directory] [type] [--clean] [fig_dirs...]"
    echo "  tex_file: コンパイルするTeXファイル名"
    echo "  directory: TeXファイルがあるディレクトリ（省略時は現在のディレクトリ）"
    echo "  type: simple または full（省略時はsimple）"
    echo "    simple: platex + dvipdfmx"
    echo "    full: platex + pbibtex + platex + platex + dvipdfmx"
    echo "  --clean: コンパイル後に中間ファイルを削除"
    echo "  fig_dirs: PNG->EPS変換を行うディレクトリ（複数指定可能）"
    echo ""
    echo "例:"
    echo "  $0 template.tex . simple fig"
    echo "  $0 template.tex . full --clean fig"
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

# PNG->EPS変換関数
convert_png_to_eps() {
    local fig_dir="$1"
    if [ ! -d "$fig_dir" ]; then
        echo "図ディレクトリが見つかりません: $fig_dir"
        return 0
    fi
    
    echo "PNG->EPS変換を実行中: $fig_dir"
    
    # ImageMagickの存在確認
    if ! command -v convert &> /dev/null; then
        echo "警告: ImageMagickが見つかりません。PNG->EPS変換をスキップします。"
        return 0
    fi
    
    local original_dir=$(pwd)
    cd "$fig_dir" || { echo "エラー: $fig_dir に移動できません"; return 1; }
    
    # PNGファイルが存在するかチェック
    if ! ls *.png 1> /dev/null 2>&1; then
        echo "PNGファイルが見つかりません: $fig_dir"
        cd "$original_dir"
        return 0
    fi
    
    local converted_count=0
    for png_file in *.png; do
        base_name="${png_file%.png}"
        eps_file="${base_name}.eps"
        
        # PNGがEPSより新しい場合のみ変換
        if [ ! -f "$eps_file" ] || [ "$png_file" -nt "$eps_file" ]; then
            echo "変換中: $png_file -> $eps_file"
            convert "$png_file" "$eps_file" && ((converted_count++))
        fi
    done
    
    echo "$fig_dir: $converted_count 件の画像を変換しました"
    cd "$original_dir"
}

echo "TeXコンパイルを開始します: $TEX_FILE (タイプ: $TYPE)"

# PNG->EPS変換を実行
if [ ${#FIG_DIRS[@]} -gt 0 ]; then
    echo "PNG->EPS変換を開始します..."
    for fig_dir in "${FIG_DIRS[@]}"; do
        convert_png_to_eps "$fig_dir"
    done
    echo "PNG->EPS変換完了"
fi

if [ "$TYPE" = "full" ]; then
    # フルコンパイル（参考文献あり）
    echo "フルコンパイルを実行します..."
    platex -interaction=nonstopmode "$TEX_FILE" || echo "1回目のplatexでエラーが発生しましたが、処理を続行します。"
    pbibtex "${TEX_FILE%.tex}" || echo "pbibtexでエラーが発生しましたが、処理を続行します。"
    platex -interaction=nonstopmode "$TEX_FILE" || echo "2回目のplatexでエラーが発生しましたが、処理を続行します。"
    platex -interaction=nonstopmode "$TEX_FILE" || echo "3回目のplatexでエラーが発生しましたが、処理を続行します。"
else
    # シンプルコンパイル
    echo "シンプルコンパイルを実行します..."
    platex -interaction=nonstopmode "$TEX_FILE" || echo "platexでエラーが発生しましたが、処理を続行します。"
fi

dvipdfmx "${TEX_FILE%.tex}.dvi" || echo "dvipdfmxでエラーが発生しましたが、処理を続行します。"

# クリーンアップ処理
if [ "$CLEAN" = true ]; then
    echo "中間ファイルを削除中..."
    rm -f *.aux *.bbl *.blg *.log *.dvi *.out *.toc *.lof *.lot *.fls *.fdb_latexmk *.synctex.gz
    echo "中間ファイルの削除完了"
fi

echo "コンパイル完了: ${TEX_FILE%.tex}.pdf が生成されました。"