class RentalRequestsController < ApplicationController
  before_action :authenticate_user!

  def index
    # How to do policy_scope on @outgoing_rental_requests?
    rental_requests = policy_scope(RentalRequest)

    @outgoing_rental_requests = rental_requests.where(user: current_user)

    @incoming_rental_requests = rental_requests.select do |request|
      request.video_cassette.user == current_user && request.status == "Pending"
    end
  end

  # def incoming_rental_requests
  #   @incoming_rental_requests = rental_requests.where(video_cassettes: { user: User.first })
  # end

  # Form to create new request will be embedded on Videos Show

  def create
    @rental_request = RentalRequest.new(rental_request_params)
    # @rental_request.video_cassette = VideoCassette.find(params[:rental_request][:video_cassette_id])
    @rental_request.user = current_user

    authorize @rental_request

    @rental_request.save
    flash.notice = "Request Submitted!"

    redirect_to video_cassette_path(@rental_request.video_cassette_id)
  end

  # Buttons tick/cross on rental_request#index
  def accept_request
    @rental_request = RentalRequest.find(params[:id])
    @rental_request.status = "Accepted"

    authorize @rental_request

    @rental_request.save
    flash.notice = "Accepted request!"

    redirect_to rental_requests_path
  end

  def reject_request
    @rental_request = RentalRequest.find(params[:id])
    @rental_request.status = "Rejected"

    authorize @rental_request

    @rental_request.save
    flash.notice = "Rejected request!"

    redirect_to rental_requests_path
  end

  private

  def rental_request_params
    params.require(:rental_request).permit(:message, :start_date, :end_date, :video_cassette_id)
  end
end
