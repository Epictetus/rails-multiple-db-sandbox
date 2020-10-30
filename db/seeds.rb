# schools
school1 = School.create!(name: 'school1')
school2 = School.create!(name: 'school2')

# users
ogawa     = User.create!(name: 'ogawa',     school_id: school1.id)
ito       = User.create!(name: 'ito',       school_id: school1.id)
suzuki    = User.create!(name: 'suzuki',    school_id: school2.id)
kobayashi = User.create!(name: 'kobayashi', school_id: school2.id)

# grades
grade1 = Grade.create!(name: 'grade1')
grade2 = Grade.create!(name: 'grade2')
grade3 = Grade.create!(name: 'grade3')

# students
Student.create!(name: 'ogawa',     user_id: ogawa.id,     grade_id: grade1.id)
Student.create!(name: 'ito',       user_id: ito.id,       grade_id: grade2.id)
Student.create!(name: 'suzuki',    user_id: suzuki.id,    grade_id: grade3.id)
Student.create!(name: 'kobayashi', user_id: kobayashi.id, grade_id: grade3.id)

