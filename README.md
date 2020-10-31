# rails-multiple-db-sandbox
Rails6からActiveRecordで複数のデータベースが利用できるようになったので試す<br>
参考：[Railsガイド|Active Record で複数のデータベース利用](https://railsguides.jp/active_record_multiple_databases.html)

やったこと
- 複数のデータベースを作成
  - commonデータベースとschoolデータベース
- primary/replicaデータベースを利用
  - commonデータベースのreplicaと、schoolデータベースのreplica
- GETリクエストはreplicaが呼び出されることを確認
- 異なるデータベースのテーブル間のJOINはできないことを確認


## バージョン

- ruby 2.7.1
- rails 6.0.3.4


## データベース構成

![image](https://user-images.githubusercontent.com/20487308/97771468-95ec7e80-1b80-11eb-86ad-8aa82d64338a.png)


## セットアップ

```sh
$ git clone https://github.com/youichiro/rails-multiple-db-sandbox.git
$ cd rails-multiple-db-sandbox
# config/database.ymlのpasswordやportなどを編集
$ bin/rails db:create
$ bin/rails db:migrate
$ bin/rails db:seed
```

## 新しいモデルを追加する手順
schoolデータベースに`Teacher`モデルを追加する手順の例

### generame model

```sh
$ bin/rails g model teacher name:string --database school

Running via Spring preloader in process 54763
      invoke  active_record
      create    db/school_migrate/20201030135726_create_teachers.rb
      create    app/models/teacher.rb
      invoke    test_unit
      create      test/models/teacher_test.rb
      create      test/fixtures/teachers.yml
```

`--database`でschoolデータベースを指定することで`db/school_migrate`ディレクトリにマイグレーションファイルが作成される

### モデルの継承クラスを変更
デフォルトでは`ApplicationRecord`を継承しているが、Schoolデータベースを使用したいので**SchoolBaseを継承する**ように変更する

```diff
- class Teacher < ApplicationRecord
+ class Teacher < SchoolBase
  end
```

### db:migrate

```sh
# 全てのマイグレーションファイルを適用する場合
$ bin/rails db:migrate

# schoolデータベースのマイグレーションファイルのみを適用する場合
$ bin/rails db:migrate:school
```

## リクエストによってprimary/replicaが切り替わっているかの確認
replicaを用意することでPOST, PUT, DELETE, PATCHのリクエストはprimaryに書き込み、GET, HEADリクエストはreplicaから読み込むようになる<br>
これを確認するために、[arproxy](https://github.com/cookpad/arproxy)を使用してクエリのログにデータベースの接続状況を表示するようにする

### arproxyの設定
- `Gemfile`に`gem arproxy`を追加して`bundle install`
- `config/initializers/arproxy.rb`に以下を記述

```ruby
if Rails.env.development? || Rails.env.test?
 require 'multiple_database_connection_logger'
 Arproxy.configure do |config|
   config.adapter = 'mysql2'
   config.use MultipleDatabaseConnectionLogger
 end
 Arproxy.enable!
end
```

- `lib/multiple_database_connection_logger.rb`に以下を記述

```ruby
class MultipleDatabaseConnectionLogger < Arproxy::Base
 def execute(sql, name = nil)
  role = ActiveRecord::Base.current_role
  name = "#{name} [#{role}]"
  super(sql, name)
 end
end
```

### リクエスト時のデータベース接続状況を確認
curlからリクエストを送信してログを見ると、呼び出されたデータベースとwritingかreadingかが表示される

index

```sh
$ curl localhost:3000/schools
```

![image](https://user-images.githubusercontent.com/20487308/97646358-c3f39500-1a92-11eb-8d5e-da37b67b457e.png)

show

```sh
$ curl localhost:3000/schools/1
```

![image](https://user-images.githubusercontent.com/20487308/97646361-c655ef00-1a92-11eb-8dd0-a128b1c9c68c.png)

create

```sh
$ curl -X POST -H 'Content-Type: application/json' -d '{"name": "school2"}' localhost:3000/schools
```

![image](https://user-images.githubusercontent.com/20487308/97646363-c81fb280-1a92-11eb-89cd-beb7cef25cd8.png)

update

```sh
$ curl -X PUT -H 'Content-Type: application/json' -d '{"name": "school1(updated)"}' localhost:3000/schools/1
```

![image](https://user-images.githubusercontent.com/20487308/97646368-c9e97600-1a92-11eb-879f-a10ffd6793f2.png)

destroy

```sh
$ curl -X DELETE http://localhost:3000/schools/3
```

![image](https://user-images.githubusercontent.com/20487308/97646373-cc4bd000-1a92-11eb-9cde-2576a183cb55.png)



## JOIN
### 同じデータベースのテーブル間はJOINできる
studentsテーブルをgradeテーブルにJOINする場合

```ruby
Grade.joins(:students).where(name: 'grade1')
```

発行されるSQL

```sql
SELECT `grades`.*
FROM `grades`
INNER JOIN `students` ON `students`.`grade_id` = `grades`.`id`
WHERE `grades`.`name` = 'grade1
```

### 異なるデータベースのテーブル間はJOINできない
studentsテーブルをusersテーブルにJOINしようとした場合

```ruby
User.joins(:students).where(name: 'ogawa')
```

発生するエラー

```
ActiveRecord::StatementInvalid (Mysql2::Error: Table 'rails_app_common_development.students' doesn't exist)
```
