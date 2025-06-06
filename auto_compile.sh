#!/bin/bash

# AnyTexGenプロジェクト用統合自動コンパイルスクリプト
# 使用方法: ./auto_compile.sh <project_path> [--clean] [additional_args...]
# 例: ./auto_compile.sh tex/jcmsi/temp
#     ./auto_compile.sh tex/seminar/temp --clean

show_help() {
    echo "AnyTexGenプロジェクト用統合自動コンパイルスクリプト"
    echo ""
    echo "使用方法: $0 <project_path> [options] [additional_args...]"
    echo ""
    echo "プロジェクトパス:"
    echo "  tex/jcmsi/temp      JCMSI論文プロジェクト"
    echo "  tex/seminar/temp    セミナー発表プロジェクト"
    echo "  tex/sice/temp       SICE論文プロジェクト"
    echo ""
    echo "オプション:"
    echo "  --clean            コンパイル後に中間ファイルを削除"
    echo "  -h, --help         このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0 tex/jcmsi/temp"
    echo "  $0 tex/seminar/temp --clean"
    echo "  $0 tex/sice/temp"
    echo ""
    echo "注意: 自動監視を停止するにはCtrl+Cを押してください"
}

if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

PROJECT_PATH="$1"
shift  # 最初の引数を削除

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="$SCRIPT_DIR/utils"

# プロジェクトパスの存在確認
if [ ! -d "$SCRIPT_DIR/$PROJECT_PATH" ]; then
    echo "エラー: プロジェクトパス '$PROJECT_PATH' が存在しません"
    echo ""
    show_help
    exit 1
fi

# プロジェクト設定を自動検出
case "$PROJECT_PATH" in
    "tex/jcmsi/temp")
        TEX_FILE="template.tex"
        COMPILE_TYPE="simple"
        FIG_DIRS="fig"
        ;;
    "tex/seminar/temp")
        TEX_FILE="template_v1.0.tex"
        COMPILE_TYPE="simple"
        FIG_DIRS="fig"
        ;;
    "tex/sice/temp")
        TEX_FILE="SICE_FES25.tex"
        COMPILE_TYPE="simple"
        FIG_DIRS="Fig"
        ;;
    *)
        echo "エラー: 未対応のプロジェクト '$PROJECT_PATH'"
        echo "対応プロジェクト: tex/jcmsi/temp, tex/seminar/temp, tex/sice/temp"
        exit 1
        ;;
esac

# utilsスクリプトを実行
echo "プロジェクト: $PROJECT_PATH"
echo "TeXファイル: $TEX_FILE (タイプ: $COMPILE_TYPE)"
echo ""

"$UTILS_DIR/auto_compile_tex.sh" "$TEX_FILE" "$SCRIPT_DIR/$PROJECT_PATH" "$COMPILE_TYPE" "$@" "$FIG_DIRS"