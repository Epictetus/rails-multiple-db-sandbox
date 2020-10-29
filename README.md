# rails-multiple-db-sandbox
Rails6からActiveRecordで複数のデータベースが利用できるようになったので試す<br>
[Railsガイド|Active Record で複数のデータベース利用](https://railsguides.jp/active_record_multiple_databases.html)

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
