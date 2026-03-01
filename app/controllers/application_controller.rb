class ApplicationController < ActionController::API
  rescue_from StandardError, with: :handle_internal_error
  rescue_from ::CustomException, with: :handle_custom_exception

  def handle_internal_error(exception)
    render json: {
      error: 'unexpected error',
      details: exception.message.split(' for #<').first,
      endpoint: "#{request.method} #{request.path}"
    }, status: :internal_server_error
  end

  def handle_custom_exception(exception)
    render json: { error: exception.message, details: exception.details }, status: exception.code
  end
end
