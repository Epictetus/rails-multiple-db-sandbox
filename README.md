# rails-multiple-db-sandbox
Rails6からActiveRecordで複数のデータベースが利用できるようになったので試す<br>
参考：[Railsガイド|Active Record で複数のデータベース利用](https://railsguides.jp/active_record_multiple_databases.html)

やったこと
- 複数のデータベースを利用
  - `commonデータベース`と`schoolデータベース`を作成
- primary/replicaデータベースを利用
  - commonデータベースのreplicaとschoolデータベースのreplicaを利用

## rails newまでのコマンド

```sh
$ ruby -v
ruby 2.7.1p83

$ rails -v
Rails 6.0.3.4

$ rails new -d mysql --api rails-multiple-db-sandbox
```

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
commonデータベースとschoolデータベースそれぞれに`Teacher`モデルを追加する手順の例

### generate migration

```sh
# commonデータベースにteachersテーブルを作成
# --databaseでcommonデータベースを指定
# db/common_migrateディレクトリにマイグレーションファイルが作成される
$ bin/rails g migration CreateTeachers name:string --database common

Running via Spring preloader in process 19119
      invoke  active_record
      create    db/common_migrate/20201029214650_create_teachers.rb


# schoolデータベースにteachersテーブルを作成
# db/school_migrateディレクトリにマイグレーションファイルが作成される
$ bin/rails g migration CreateTeachers name:string --database school

Running via Spring preloader in process 19604
      invoke  active_record
      create    db/school_migrate/20201029214951_create_teachers.rb
```

### db:migrate

```sh
$ bin/rails db:migrate  # 全てのマイグレーションファイルを適用する
$ bin/rails db:migrate:common  # commonデータベースのマイグレーションファイルを適用する
$ bin/rails db:migrate:school  # schoolデータベースのマイグレーションファイルを適用する
```

### モデルファイルの作成

- `app/models/common/teacher.rb`を作成する
  - **Common::Baseを継承した**クラスを作成する

```rb:app/models/common/teacher.rb
class Common::Teacher < Common::Base
end
```

- `app/models/school/teacher.rb`を作成する
  - **School::Baseを継承した**クラスを作成する

```rb:app/models/school/teacher.rb
class School::Teacher < School::Base
end
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

### リクエストログを確認
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

