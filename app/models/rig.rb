class Rig < ActiveRecord::Base
    attr_accessible :name,
                    :rig_memberships_count

    acts_as_tenant(:company)

    validates :name, presence: true, length: {maximum: 50}
    validates_uniqueness_of :name, :case_sensitive => false, scope: :company_id
    validates_presence_of :company

    belongs_to :company

    has_many :wells
    has_many :rig_memberships, dependent: :destroy, foreign_key: "rig_id", order: "created_at ASC"
    has_many :members, through: :rig_memberships, source: :user

    searchable do
        text :name, :as => :code_textp
        integer :company_id

        string :name_sort do
            name
        end
    end

    def self.search(options, company)
        Sunspot.search(Rig) do
            fulltext options[:search].present? ? options[:search] : options[:term]
            with(:company_id, company.id)
            order_by :name_sort
            paginate :page => options[:page], :per_page => 20
        end
    end

    def color
        if !self.name.blank?
            Digest::MD5.hexdigest(self.name)[0..5]
        else
            '666666'
        end
    end

    def self.get_rig_rop rig_id, time_range
        months = []
        result = DrillingLog.joins(job: {well: :rig}).where("rigs.id = ?", rig_id).where("drilling_logs.updated_at >= ?", Date.today - 1.year).select("coalesce(drilling_logs.drilling_rop, 0) AS rop, coalesce(drilling_logs.rotate_rop, 0) AS rotate_rop, coalesce(drilling_logs.slide_rop, 0) AS slide_rop, drilling_logs.updated_at as date, drilling_logs.npt as npt, drilling_logs.total_circulation_time as total_circulation, rigs.name as rig_name, jobs.failures_count as failures")
        result = result.group_by { |d| Date.strptime(d.date, '%Y-%m-%d').month }

        12.times do |m|
            months << {month: Date::MONTHNAMES[m + 1]}
        end
        result.each do |group|
            hash = months[group[0] - 1]

            if group[1].any?
                count = group[1].count
                rop = 0
                rotate = 0
                slide = 0
                failures = 0
                npt = 0
                total_circulation = 0
                group[1].each do |dl|
                    rop += dl[:rop]
                    rotate += dl[:rotate_rop]
                    slide += dl[:slide_rop]
                    npt += dl[:npt]
                    total_circulation += dl[:total_circulation].to_f
                    failures += dl[:failures].to_i
                end

                hash[:rop] = (rop / count.to_f).round(1)
                hash[:rotate_rop] = (rotate / count.to_f).round(1)
                hash[:slide_rop] = (slide / count.to_f).round(1)
                hash[:npt] = (npt / total_circulation.to_f * 1000.0).round(1)
                hash[:failures] = failures
            end
        end

        months
    end

    def self.get_rig_rops time_range
        months = []
        result = DrillingLog.joins(job: {well: :rig}).where("drilling_logs.updated_at >= ?", Date.today - 1.year).select("coalesce(drilling_logs.drilling_rop, 0) AS rop, drilling_logs.updated_at as date, wells.rig_id as rig_id, drilling_logs.npt as npt, coalesce(drilling_logs.total_circulation_time, 0) as total_circulation, rigs.name as rig_name, coalesce(jobs.failures_count, 0) as failures")
        result = result.group_by { |d| Date.strptime(d.date, '%Y-%m-%d').month }

        12.times do |m|
            months << {month: Date::MONTHNAMES[m + 1]}
        end
        result.each do |group|
            hash = months[group[0] - 1]

            rigs = group[1].group_by { |dl| dl[:rig_name] }

            avg_rop = 0
            failures = 0
            npt = 0
            total_circulation = 0
            group[1].each do |dl|
                avg_rop += dl[:rop]
                npt += dl[:npt]
                total_circulation += dl[:total_circulation].to_f
                failures += dl[:failures].to_i
            end
            if group[1].any?
                hash[:avg_rop] = (avg_rop.to_f / group[1].length.to_f).round(1)
                hash[:npt] = (npt / total_circulation.to_f * 1000.0).round(1)
                hash[:failures] = failures
            end

            rigs.each do |rig_group|
                sum = 0
                rig_group[1].each do |r|
                    sum += r[:rop]
                end
                hash[rig_group[0]] = (sum.to_f / rig_group[1].count.to_f).round(1)
            end
        end

        months
    end
end
