### 目的
tex_sampleの内容を英語化し，product_sice/SICE_FES25.tex
に移植しています．以下の点を修正してください．
・Fig. 3 Trajectory and view frustum of an agent tracking
a single feature point.は不要．
・SIMULATION RESULTS内の各結果について，パラメータ文中に記載する．
    ・tex_sampleを参照
・QPにおける各行列などすべての変数を説明する．
    ・tex_sampleを参照

; ・章立てはmaterial/TOC.mdに従う．
;     ・tex_sampleからTOCに沿った部分のみを移植してください
; ・論文化における適切なクオリティはmisc/funada.mdを参考にしてください
; ・tex_sampleで使用されている画像で必要なものはproduct_sice/Figに配置してください
;     ・convert_png_to_eps.shを実行してEPSファイルに変換してください

### Tex執筆規則
・1カラム
・論文形式の執筆ではデータサイズが大きくなるため，章ごとにファイルを分割する．
・数式はすべて以下の用にequation環境及びaligned環境で表現する．
・すべての数式にラベル\labelを付ける
・!!!重要!!! \mathbb, \mathcal, \mathfrakなど
テキストの記体コマンドは{}で囲むこと
\begin{equation}
\begin{aligned}
\mathbf{u}^* = \arg\min_{{\mathcal{u}} \in {\mathfrak{R}}^m} & \|{\mathrm{u}} - {\mathbf{u}}_{\text{nom}}\|^2 \\
\text{s.t.} & L_f h({\mathbf{x}}) + L_g h({\mathbf{x}}){\mathbf{u}} + \alpha(h({\mathbf{x}})) \geq 0
\label{eq:opt}
\end{aligned}
\end{equation}

### 資料及びコード実装規則
・あなたは出力文字数が一定値を超えると途切れるようになっています．長い文章及びコードを出力する場合は，適宜区切り，write_in_fileではなくreplase_in_fileを用いてファイルを更新してください．
・実装したコードをテストして，validationが完了したことを確認してください．あらゆるエラーを排除してください．

### 実行
`compile.sh`を実行してvalidationを実行してください。