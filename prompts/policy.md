### 目的
既存の日本語論文の内容をトップカンファレンスに通せる様に推敲しつつ，英語論文に変換する．
### 手順
1. MSCS2025_Arita_TN_rev1.pdfとMSCS2025_Arita.pptxを
   OCRしてtext化
	1. OCRしたtext等はmiscに保存する．
	2. pptxには重要な数式画像が含まれているので必ずpdf化してからOCRする
2. 概要部分を60QAに流し込み
	1. 60QAもOCRする必要あり
	2. 60QAを書き込んだ60QA_answer.mdを作成する
3. 60QAで答えられていない部分をサーベイに投げる
4. 2,3繰り返す
	1. 執筆者にしか答えられない場合はconsoleに書き込む
5. 60QA及び元原稿(日本語)をまとめて英語原稿に書き換える
	1. texで執筆，フォーマットはproduct_tempに合わせる
	2. 完成したらcompileしてvalidation
	3. 元原稿に存在した図表はblank図表として穴抜きにする．
	4. 追加で必要な図表などの結果部分はその旨を記載して穴抜きにする
	5. product_v2内にtexファイルを作成する

### サーベイ規則
サーベイは `surveys/task_{i}/request.md`を作成してサーベイ要件をまとめる．
サーベイはdeep researchを使うため，自律的には行わずrequest.mdを作成した時点で停止しanswer.mdの作成を待つ．

### OCR規則
`utils/run_mistral_ocr.py`スクリプトを使ってOCR，その他の拡張子はpdf化してからOCRする．OCRしたtext等はmiscに保存する．
- pythonのパッケージ管理はvenv仮想環境を使用