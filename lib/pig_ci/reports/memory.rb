class PigCi::Reports::Memory < PigCi::Reports
  def self.column_keys
    [:key, :max, :min, :mean, :number_of_requests]
  end
end
