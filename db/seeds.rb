# schools
school1 = Common::School.create!(name: 'school1')
school2 = Common::School.create!(name: 'school2')

# users
ogawa     = Common::User.create!(name: 'ogawa',     school_id: school1.id)
ito       = Common::User.create!(name: 'ito',       school_id: school1.id)
suzuki    = Common::User.create!(name: 'suzuki',    school_id: school2.id)
kobayashi = Common::User.create!(name: 'kobayashi', school_id: school2.id)

# grades
grade1 = School::Grade.create!(name: 'grade1')
grade2 = School::Grade.create!(name: 'grade2')
grade3 = School::Grade.create!(name: 'grade3')

# students
School::Student.create!(name: 'ogawa',     user_id: ogawa.id,     grade_id: grade1.id)
School::Student.create!(name: 'ito',       user_id: ito.id,       grade_id: grade2.id)
School::Student.create!(name: 'suzuki',    user_id: suzuki.id,    grade_id: grade3.id)
School::Student.create!(name: 'kobayashi', user_id: kobayashi.id, grade_id: grade3.id)

