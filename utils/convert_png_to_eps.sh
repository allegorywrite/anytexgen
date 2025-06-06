#!/bin/bash

# PNGファイルをEPSファイルに変換するスクリプト
# 使用方法: ./convert_png_to_eps.sh [options] [directories...]
# ImageMagickが必要です

# ヘルプ表示
show_help() {
    echo "使用方法: $0 [options] [directories...]"
    echo ""
    echo "オプション:"
    echo "  -f, --force     既存のEPSファイルを強制上書き"
    echo "  -r, --recursive サブディレクトリも再帰的に処理"
    echo "  -h, --help      このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0                    現在のディレクトリを処理"
    echo "  $0 fig Fig            figとFigディレクトリを処理"
    echo "  $0 -f fig            figディレクトリを強制上書きで処理"
    echo "  $0 -r .              現在のディレクトリを再帰的に処理"
}

# デフォルト値
FORCE=false
RECURSIVE=false
DIRS=()

# 引数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE=true
            shift
            ;;
        -r|--recursive)
            RECURSIVE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo "エラー: 不明なオプション '$1'"
            show_help
            exit 1
            ;;
        *)
            DIRS+=("$1")
            shift
            ;;
    esac
done

# ディレクトリが指定されていない場合は現在のディレクトリを使用
if [ ${#DIRS[@]} -eq 0 ]; then
    DIRS=(".")
fi

# ImageMagickのconvertコマンドの存在確認
if ! command -v convert &> /dev/null; then
    echo "エラー: ImageMagickのconvertコマンドが見つかりません。ImageMagickをインストールしてください。"
    exit 1
fi

# PNG変換関数
convert_png_in_dir() {
    local dir="$1"
    local original_dir=$(pwd)
    
    # ディレクトリに移動
    cd "$dir" || { echo "エラー: ディレクトリ '$dir' に移動できません"; return 1; }
    
    echo "PNGからEPSへの変換を開始します（ディレクトリ: $dir）"
    
    # PNGファイルの存在確認
    if ! ls *.png 1> /dev/null 2>&1; then
        echo "PNGファイルが見つかりません: $dir"
        cd "$original_dir"
        return 0
    fi
    
    local converted_count=0
    local skipped_count=0
    
    # すべてのPNGファイルをループ処理
    for png_file in *.png; do
        # ファイル名から拡張子を除いた部分を取得
        base_name="${png_file%.png}"
        eps_file="${base_name}.eps"
        
        # 既にEPSファイルが存在する場合の処理
        if [ -f "$eps_file" ] && [ "$FORCE" = false ]; then
            echo "既に存在します: $eps_file - スキップします"
            ((skipped_count++))
            continue
        fi
        
        if [ -f "$eps_file" ] && [ "$FORCE" = true ]; then
            echo "上書きします: $eps_file"
        fi
        
        echo "変換中: $png_file -> $eps_file"
        
        # PNGをEPSに変換
        convert "$png_file" "$eps_file"
        
        # 変換が成功したか確認
        if [ $? -eq 0 ]; then
            echo "変換成功: $eps_file"
            ((converted_count++))
        else
            echo "変換失敗: $png_file"
        fi
    done
    
    echo "ディレクトリ $dir の処理完了: 変換 $converted_count 件, スキップ $skipped_count 件"
    
    # 元のディレクトリに戻る
    cd "$original_dir"
}

# 再帰処理関数
process_recursive() {
    local dir="$1"
    
    # 現在のディレクトリを処理
    convert_png_in_dir "$dir"
    
    # サブディレクトリを再帰的に処理
    find "$dir" -type d -not -path "$dir" | while read -r subdir; do
        convert_png_in_dir "$subdir"
    done
}

# メイン処理
total_converted=0
total_skipped=0

for dir in "${DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "エラー: ディレクトリ '$dir' が存在しません"
        continue
    fi
    
    if [ "$RECURSIVE" = true ]; then
        process_recursive "$dir"
    else
        convert_png_in_dir "$dir"
    fi
done

echo "全体の変換処理が完了しました"