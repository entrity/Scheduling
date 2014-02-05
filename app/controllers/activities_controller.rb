class ActivitiesController < ApplicationController

  respond_to :json

  def index
    raise 'todo'
  end

  def create
    @activity = Activity.create activity_params
    respond_with @activity
  end

  def update
    @activity = Activity.find params[:id]
    respond_with @activity.update_attributes activity_params
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

private

  def activity_params
    params.require(:activity).permit([
      :name, :description, :start, :finish, :bookings_available, :price,
      {activity_factory:[ :name, :descript, :start_date, :start_time, :finish_date, :finish_time, :price ]}
      ])
  end
  
end
