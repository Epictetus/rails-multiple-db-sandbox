class User < CommonBase
  belongs_to :school
  has_many :students
end
