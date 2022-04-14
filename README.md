![Tests](https://github.com/monade/paramoid/actions/workflows/test.yml/badge.svg)

# Paramoid

Are you a bit _paranoid_ about your Rails application params? Try _paramoid_!

It's a replacement / extension for Rails Strong Parameters that allows to declare complex params structures with a super cool DSL, supporting required params, default values, groups, arrays and more.

## Installation

Add the gem to your Gemfile

```ruby
  gem 'paramoid', github: 'monade/paramoid'
```

## Usage
Declare a class extending `Paramoid::Base`.

```ruby
class PersonParamsSanitizer < Paramoid::Base
  # @param [User] user
  def initialize(user = nil)
    params! :first_name, :last_name, :gender

    param! :email, transformer: ->(data) { data&.downcase }

    param! :current_user_id, required: true

    param! :an_object_filtered
    param! :an_array_filtered

    array! :an_array_unfiltered

    param! :role if user&.admin?

    default! :some_default, 1

    group! :contact, as: :contact_attributes do
      params! :id, :first_name, :last_name, :birth_date, :birth_place, :phone, :role, :fiscal_code
    end
  end
end
```

Then use it in your controller:

```ruby
class PeopleController < ApplicationController

  def create
    @person = Person.create!(person_params)
  end

  private

  def person_params
    # You can pass the current user or nil
    PersonParamsSanitizer.new(current_user).sanitize(params)
  end
end
```

## TODO
* Params type checking and regexp
* Using the DSL directly in the controller
* Auto-load params sanitizer by name (Rails magic stuff)
* Required params
