class EventController < ApplicationController
  skip_before_action :verify_authenticity_token
  rescue_from ActiveRecord::RecordNotUnique, with: :already_booked

  def list
    events = Event.all

    if events.present?
      render json: events.to_json
    else
      render json: {  success: false }, status: :not_found
    end
  end

  def new
    full_params
    if EventService.create(params[:event])
      redirect_to :action => 'list'
    else
      render json: {  success: false }, status: :bad_request
    end
  end

  def full_params
    params.require(:event).permit(:start_date, :end_date)
  end

  def already_booked
    render json: {  success: false, errors: 'time slot already booked' },  status: :bad_request
  end

  def available
    avail = EventService.find(
      year: params[:year],
      week: params[:week]
    )

    render json: avail.to_json
  end
end
