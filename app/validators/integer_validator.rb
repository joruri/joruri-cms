class IntegerValidator < ActiveModel::Validator
  def validate(record)
    integer_columns = record.class.columns.select { |c| c.type == :integer }
    integer_columns.each do |column|
      if (value = record[column.name])
        min, max = min_max(column)
        if value <= min
          record.errors.add(column.name, :greater_than, count: min)
        end
        if value >= max
          record.errors.add(column.name, :less_than, count: max)
        end
      end
    end
  end

  private

  def min_max(column)
    max = 1 << ((column.limit || 4) * 8 - 1)
    min = -max
    return min, max
  end
end
