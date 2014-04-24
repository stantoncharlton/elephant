class Shipment < ActiveRecord::Base
    attr_accessible :accepted_at,
                    :status,
                    :from_name,
                    :to_name,
                    :from_editable,
                    :part_memberships_count

    acts_as_tenant(:company)


    validates :company, presence: true
    validates :district, presence: true
    validates :user, presence: true

    belongs_to :company
    belongs_to :district
    belongs_to :user
    belongs_to :accepted_by, class_name: 'User'

    belongs_to :from, :polymorphic => true
    belongs_to :to, :polymorphic => true

    belongs_to :shipper

    has_many :part_memberships, order: "name ASC", :conditions => "part_memberships.job_id IS NULL", :dependent => :destroy
    has_many :job_notes

    CREATING = 0
    AWAITING_SHIPMENT = 1
    IN_TRANSIT = 2
    COMPLETE = 3

    WAREHOUSE = 1
    SUPPLIER = 2
    JOB = 3

    def receive_shipment user
        shipment = self
        Shipment.transaction do
            shipment.status = Shipment::COMPLETE
            shipment.accepted_by = user
            shipment.accepted_at = Time.zone.now

            shipment.part_memberships.each do |pm|

                pm.update_attribute(:received, true)

                case pm.to_type
                    when Job.name
                        part_membership = pm.duplicate
                        part_membership.job = pm.to
                        part_membership.job_part_membership = pm
                        part_membership.shipment = shipment
                        part_membership.save

                        if part_membership.part.present?
                            part_membership.part.status = Part::ON_JOB
                            part_membership.part.current_job = pm.to
                            part_membership.part.save
                            AssetActivity.delay.add(user, AssetActivity::RECEIVED_AT_JOB, part_membership.part, pm.to)
                        end
                    when Warehouse.name
                        if pm.part.present?
                            pm.part.status = Part::AVAILABLE
                            pm.part.current_job = nil
                            pm.part.warehouse = pm.to
                            pm.part.save
                            AssetActivity.delay.add(user, AssetActivity::RECEIVED_AT_WAREHOUSE, pm.part, pm.to)
                        end
                    when Supplier.name
                        if pm.part.present?
                            pm.part.status = Part::AVAILABLE
                            pm.part.current_job = nil
                            pm.part.save
                        end
                end


            end

            shipment.save
        end
    end

end
