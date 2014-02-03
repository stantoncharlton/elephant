class AssetActivity < ActiveRecord::Base
  attr_accessible :activity_type,
                  :user_name

  acts_as_tenant(:company)

  belongs_to :company
  belongs_to :user
  belongs_to :part
  belongs_to :target, :polymorphic => true

  ADDED_TO_JOB = 1
  DELETED_FROM_JOB = 2
  ADDED_TO_SHIPMENT = 3
  DELETED_FROM_SHIPMENT = 4
  MOVED_TO_WAREHOUSE = 5
  RECEIVED_AT_WAREHOUSE = 6
  RECEIVED_AT_JOB = 7
  CREATED = 10

  def message
      case self.activity_type
          when ADDED_TO_JOB
              "Added to Job"
          when RECEIVED_AT_JOB
              "Received at Job"
          when DELETED_FROM_JOB
              "Removed from Job"
          when ADDED_TO_SHIPMENT
              "Added to Shipment"
          when DELETED_FROM_SHIPMENT
              "Removed from Shipment"
          when MOVED_TO_WAREHOUSE
              "Moved to Warehouse"
          when RECEIVED_AT_WAREHOUSE
              "Received at Warehouse"
          when CREATED
              "Asset Created"
      end
  end

  def self.add(user, activity_type, part, target)
      return false if user.nil? || user.company.nil? || activity_type.blank? || part.nil?

      activity = AssetActivity.new(activity_type: activity_type)
      activity.target = target
      activity.user = user
      if user
          activity.user_name = user.name
      end
      activity.company = user.company
      activity.part = part

      activity.save!
  end

end
