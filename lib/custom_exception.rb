# frozen_string_literal: true

class CustomException < StandardError
  attr_reader :code, :details

  def initialize(message, error_code = 500, details = '')
    super(message)
    @code = error_code
    @details = details
  end
end
