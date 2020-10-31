class DemoController < ApplicationController
  def index
    # 同じDBのテーブルなのでJOINできる
    # SELECT `grades`.* FROM `grades` INNER JOIN `students` ON `students`.`grade_id` = `grades`.`id` WHERE `grades`.`id` = 4
    demo = Grade.joins(:students).where(name: 'grade1')

    # 異なるDBのテーブルなのでJOINできない
    # ActiveRecord::StatementInvalid (Mysql2::Error: Table 'rails_app_common_development.students' doesn't exist)
    demo = User.joins(:students).where(name: 'ogawa')

    render json: demo
  end
end
