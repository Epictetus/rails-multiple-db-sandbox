class Common::Base < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :common, reading: :common_replica }
end

