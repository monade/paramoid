class PersonParamsSanitizer < Paramoid::Base
  # @param [User] user
  def initialize(user = nil)
    params! :first_name, :last_name, :gender

    param! :email, transformer: ->(data) { data&.downcase }

    param! :current_user_id, required: true

    param! :an_object_filtered
    param! :an_array_filtered

    array! :an_array_unfiltered

    param! :role if user.admin?

    default! :some_default, 1

    group! :contact, as: :contact_attributes do
      params! :id, :first_name, :last_name, :birth_date, :birth_place, :phone, :role, :fiscal_code
    end
  end
end
