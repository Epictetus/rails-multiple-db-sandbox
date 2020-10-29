class MultipleDatabaseConnectionLogger < Arproxy::Base
  def execute(sql, name = nil)
    role = ActiveRecord::Base.current_role
    name = "#{name} [#{role}]"
    super(sql, name)
  end
end
