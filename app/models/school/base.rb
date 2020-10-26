class SchoolBase < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :school, reading: :school_replica }
end

