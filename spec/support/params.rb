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

class ComplexParamsSanitizer < Paramoid::Base
  def initialize(user = nil)
    group :person, as: :person_attributes do
      params :id, :full_name

      if user.admin?
        param :role, default: :admin
      else
        default :role, :user
      end
    end

    group :buyer do
      group :payment_method do
        param :id, required: true, as: :uuid
      end
    end

    array :items do
      params :id, :name

      default :price, 0
      param :discount, transformer: ->(data) { data&.to_f / 100 } if user.admin?

      array :sub_items do
        param :id
        default :price, 0
      end
    end

    default :total, 0
    param :name, required: true
  end
end
