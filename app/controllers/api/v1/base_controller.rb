class Api::V1::BaseController < ApplicationController
  # Skip CSRF verification for API requests (token is verified via headers)
  skip_before_action :verify_authenticity_token

  # Ensure user is authenticated
  before_action :authenticate_user!

  # Set JSON response format
  respond_to :json

  private

  # Standardized success response
  def render_success(data, meta: nil, status: :ok)
    response = { data: data }
    response[:meta] = meta if meta.present?
    render json: response, status: status
  end

  # Standardized error response
  def render_error(message, status: :unprocessable_entity, errors: nil)
    response = { error: message }
    response[:errors] = errors if errors.present?
    render json: response, status: status
  end

  # Handle pagination metadata
  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      per_page: collection.limit_value
    }
  end
end
