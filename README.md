# ABCanalysis

# URL

# ER図
<img width="1051" alt="スクリーンショット 2023-10-10 15 56 26" src="https://github.com/dousi-sputnik/analysis/assets/97434344/f3325d12-d134-4942-99c3-b3cffff95b5c">

# 概要
当サイトはABC分析に基づいた商品在庫管理を容易にするためのシステムを提供します。
具体的には以下のことが可能です。
  1. Excel(numbersなど)のシートからコピー&ペーストすることで、バラバラの情報を売上高の高い順から降順に出力されます。
  2. 出力したABC分析はExcel形式でダウンロード可能です。
  3. 最大500行まで入力することができます。またABC分析表の保存も最大5つまで可能で、ネット環境があればいつでも結果を確認することができます。
  4. YahooAPIと連携しているため出力されたJANコードを直接クリック(もしくは検索画面に半角数字で直接入力)することで商品の概要の情報を取得できます。またそのページからYahooショッピングの該当商品へのリンクもあります。

# 使用技術
 ・ Ruby 3.2.2
 ・ Ruby on Rails 6.1.7
 ・ MySQL 8.0
 ・ Puma
 ・ AWS S3
 ・ Docker/Docker-compose

 ・ CircleCI CI/CD
 ・ RSpec
　　・ Yahoo! JAPAN Web API

# 機能一覧
 ・ ユーザー登録、ログイン機能(devise)
 ・ 外部API関連(httparty)

# テスト
 ・ RSpec
   ・ 単体テスト(modle)
   ・　　機能テスト(request)
   ・ 統合テスト(system)

# 構文チェック
 ・ rubocop(rubocop-airbnb)
