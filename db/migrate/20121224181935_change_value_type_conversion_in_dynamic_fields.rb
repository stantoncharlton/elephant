class ChangeValueTypeConversionInDynamicFields < ActiveRecord::Migration
  def up
      change_column :dynamic_fields, :value_type_conversion, :integer
  end

  def down
  end
end
