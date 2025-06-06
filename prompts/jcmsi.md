# 目的
material/memo.mdの内容を英語論文に変換し，product_jcmsi/template.tex
を執筆してください．
各章ごとにファイルを分割してproduct_jcmsi/sectionsに配置してください．

- シングルカラム
- 英語
- Simulationの章は省略
- 画像は省略
- 元となるマークダウンデータはコアの理論部分のみであるため，
論文執筆の際には各変数の説明, \Eqrefによる数式への言及, 意図の説明など論文に適切な文章に変更すること．
- 論文化における適切なクオリティはmisc/funada.mdを参考にする
- 参考文献はproduct_jcmsi/sections/references.texに記載して適切に引用すること

=>

material/proof.md
の内容を元に，
product_jcmsi/sections/convergence.tex
の各proposition, lemma, theoremに正しい証明を加えて下さい．
また，その内容を日本語に翻訳して
product_jcmsi_ja/sections/convergence.tex
に加えて下さい．
更に，その内容を小学生レベルの説明で
product_jcmsi_easy/sections/convergence.tex
に加えて下さい．

### 章立て
1. Introduction
	1. Background
        material/survey.mdを参考にする
	2. Related Work
        material/survey.mdを参考にする
	3. Contributions
        material/survey.mdを参考にする
2. Preliminary
	1. Stein Variational Gradient Descent
		product_en/temp_en_modified.texを用いる．
	2. Alternating Direction Method of Multipliers
3. Problem Formulation
	1. Notation on SE(3)
		product_en/temp_en_modified.texを用いる．
	2. Deterministic problem formulation for PGO
	3. Probabilistic problem formulation for PGO
		{Probabilistic problem formulation (KL minimization) and PGO as a special case}
4. Probabilistic Multi-Agent Pose Graph Optimization on SE(3)
	1. Mean-Field Factorization of the Joint Posterior
	2. ADMM Updates for Distributed KL Minimization
5. Evaluation via simulation
	1. Two-dimensional Case
	2. Three-dimensional Case
6. Conclusion

### Tex執筆規則
- 論文形式の執筆ではデータサイズが大きくなるため，章ごとにファイルを分割する
- 数式はすべて以下の用にequation環境及びaligned環境で表現する
- すべての数式にラベル\labelを付ける
- !!!重要!!! \mathbb, \mathcal, \mathfrakなど
テキストの記体コマンドは{}で囲むこと
\begin{equation}
\begin{aligned}
\mathbf{u}^* = \arg\min_{{\mathcal{u}} \in {\mathfrak{R}}^m} & \|{\mathrm{u}} - {\mathbf{u}}_{\text{nom}}\|^2 \\
\text{s.t.} & L_f h({\mathbf{x}}) + L_g h({\mathbf{x}}){\mathbf{u}} + \alpha(h({\mathbf{x}})) \geq 0
\label{eq:opt}
\end{aligned}
\end{equation}

### 資料及びコード実装規則
- あなたは出力文字数が一定値を超えると途切れるようになっています．長い文章及びコードを出力する場合は，適宜区切り，write_in_fileではなくreplase_in_fileを用いてファイルを更新してください．
- 実装したコードをテストして，validationが完了したことを確認してください．あらゆるエラーを排除してください．

### 実行
`compile.sh`を実行してvalidationを実行してください。