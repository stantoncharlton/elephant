class DrillingLog < ActiveRecord::Base
  attr_accessible :below_rotary, :circulation_hours, :company_id, :document_id, :ream_hours, :rop, :rotary_footage_pct, :rotary_hours_pct, :rotate_footage, :rotate_hours, :rotate_rop, :slide_footage_pct, :slide_footgae, :slide_hours, :slide_hours_pct, :slide_rop, :total_drilled
end
