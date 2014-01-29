class Shipment < ActiveRecord::Base
    attr_accessible :accepted_at,
                    :status,
                    :from_name,
                    :to_name,
                    :from_editable

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

    has_many :part_memberships, order: "name ASC", :conditions => "part_memberships.job_id IS NULL", :dependent => :destroy
    has_many :job_notes

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

            if shipment.to.present?
                shipment.part_memberships.each do |pm|

                    pm.update_attribute(:received, true)

                    case shipment.to_type
                        when Job.name
                            part_membership = pm.duplicate
                            part_membership.job = shipment.to
                            part_membership.job_part_membership = pm
                            part_membership.shipment = shipment
                            part_membership.save

                            if part_membership.part_type == PartMembership::INVENTORY && part_membership.part.present?
                                part_membership.part.status = Part::ON_JOB
                                part_membership.part.current_job = shipment.to
                                part_membership.part.save
                            end
                        when Warehouse.name
                            if pm.part_type == PartMembership::INVENTORY && pm.part.present?
                                pm.part.status = Part::AVAILABLE
                                pm.part.current_job = nil
                                pm.part.warehouse = shipment.to
                                pm.part.save
                            end
                        when Supplier.name
                            if pm.part_type == PartMembership::INVENTORY && pm.part.present?
                                pm.part.status = Part::AVAILABLE
                                pm.part.current_job = nil
                                pm.part.save
                            end
                    end


                end
            end

            shipment.save
        end
    end

end
