require 'ostruct'

class PeopleInlineController < ActionController::Base

  def index
    create_params
  end

  protected

  def create_params
    sanitize_params! do
      params! :first_name, :last_name
      param! :email, transformer: ->(data) { data&.downcase }
    end
  end
end

class PeopleController < ActionController::Base
  def index
    create_params
  end

  protected

  def current_user
    OpenStruct.new(admin?: true)
  end

  def create_params
    sanitize_params!
  end
end

