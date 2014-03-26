class JobCostsController < ApplicationController
    before_filter :signed_in_user, only: [:show, :new, :create, :edit, :update, :destroy]

    def show

    end

    def new

    end

    def create
        job_id = params[:job_cost][:job_id]
        params[:job_cost].delete(:job_id)
        @job = Job.find_by_id(job_id)

        charge_at = params[:job_cost][:charge_at]
        params[:job_cost].delete(:charge_at)

        price = params[:job_cost][:price]
        params[:job_cost].delete(:price)

        @job_cost = JobCost.new(params[:job_cost])
        @job_cost.company = current_user.company
        @job_cost.user = current_user
        @job_cost.job = @job
        @job_cost.price = price.to_s.gsub(/,/, '').to_f
        date = Date.strptime("#{charge_at}", '%m/%d/%Y')
        @job_cost.charge_at = Time.zone.parse("#{date.year}-#{date.month}-#{date.day}")
        if @job_cost.save
            @job.update_attribute(:total_cost, @job.job_costs.any? ? @job.job_costs.map { |jc| jc.price * jc.quantity }.reduce(:+) : 0.0)
        end
    end

    def edit

    end

    def update

    end

    def destroy
        @job_cost = JobCost.find_by_id(params[:id])
        @job = @job_cost.job
        not_found unless @job_cost.present?
        if @job_cost.destroy
            @job.update_attribute(:total_cost, @job.job_costs.any? ? @job.job_costs.map { |jc| jc.price * jc.quantity }.reduce(:+) : 0.0)
        end
    end

end
