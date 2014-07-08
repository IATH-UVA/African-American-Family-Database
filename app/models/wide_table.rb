class WideTable < ActiveRecord::Base
  set_table_name 'src_table_data_wide'
  set_primary_key 'src_table_data_wide_id'
  has_many 'comments'
  
  default_scope order('src_table_data_wide_id')
  paginates_per 50
	# as per https://github.com/amatsuda/kaminari/wiki/Kaminari-recipes#user-content--dont-forget-to-add-an-order-scope

  def to_label
    "#{first_name} #{last_name} - #{age.ceil if age != nil} - #{birth_year}"
  end
  
  def full_name
    "#{first_name} #{last_name}".strip
  end
end
