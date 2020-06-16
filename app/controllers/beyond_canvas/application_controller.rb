# frozen_string_literal: true

module BeyondCanvas
  class ApplicationController < ActionController::Base # :nodoc:
    protect_from_forgery with: :exception

    include ::BeyondCanvas::StatusCodes
  end
end
