class ActivitiesController < ApplicationController

  respond_to :json

  # Optionally supply +:start+ and +:finish+ to limit the times of 
  # events scoped. +:start+ defaults to the current time.
  # Optionally supply +:limit+ to specify the maximum number of records
  # returned. This defaults to 50.
  def index
    @activities = Activity.where('deleted IS NULL OR deleted != 1')
    @activities = @activities.merge Activity.where(["start >= ?", params[:start] || Time.now])
    @activities = @activities.merge Activity.where(["finish <= ?", params[:finish]]) if params[:finish]
    @activities = @activities.merge Activity.limit(params[:limit] || 50)
    respond_with @activities
  end

  # For recurring activity, <tt>params[:activity]</tt> should contain 
  # nested attributes for associated +ActivityFactory+.
  def create
    @activity = Activity.create activity_params
    status = @activity.new_record? ? 400 : 201
    if @activity.recurrence
      render json: @activity.activity_factory.activities.as_json, status:status
    else
      respond_with @activity, status:status
    end
  end

  def update
    @activity = Activity.find params[:id]
    @activity.update_attributes activity_params
    respond_with @activity
  end

  def destroy
    @activity = Activity.find params[:id]
    @activity.inspect
    success = @activity.destroy
    respond_with success
  end

  def show
    @activity = Activity.find params[:id]
    respond_with @activity
  end

  def add_booking
    @activity = Activity.find params[:id]
    if @activity.bookings_available.try :>, 0
      @booking = @activity.bookings.create name:params[:name]
      render json: @booking.as_json, status:201
    else
      render json:{error:'no bookings available'}, status:418
    end
  end

private

  def activity_params
    params.require(:activity).permit([
      *(Activity.columns.map(&:name) - %w[id activity_factory_id created_at updated_at deleted]),
      :recurrence => (ActivityFactory.columns.map(&:name) - %w[id created_at updated_at deleted])
    ])
  end
  
end
