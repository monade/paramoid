![Tests](https://github.com/monade/paramoid/actions/workflows/test.yml/badge.svg)
[![Gem Version](https://badge.fury.io/rb/paramoid.svg)](https://badge.fury.io/rb/paramoid)

# Paramoid

Getting _paranoid_ about your Rails application params? Try _paramoid_!

Paramoid is an extension for Rails Strong Parameters that allows to sanitize complex params structures with a super cool DSL, supporting:

* Required params and default values
* A simplified nested structures management
* Conditional sanitization, based on user auth, role or custom logic
* Renaming and remapping parameter names

## Installation

Add the gem to your Gemfile

```ruby
gem 'paramoid'
```

and run the `bundle install` command.

## Usage
Declare a class extending `Paramoid::Base`.

```ruby
class PersonParamsSanitizer < Paramoid::Base
  # @param [User] user
  def initialize(user = nil)
    params! :first_name, :last_name

    group! :address_attributes do
      params! :id, :road, :town, :state, :zip_code, :country
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
    # The name is automatically inferred by the controller name
    sanitize_params!
    # Or you can instantiate a custom one
    # You can pass the current user or nil
    # CustomPersonParamsSanitizer.new(current_user).sanitize(params)
  end
end
```

### param! vs params! vs group! vs array!
Paramoid is based on Rails Strong Parameters and it's inheriting its behaviour.

* `param!` is used to permit a single scalar parameter. `param! :name` is equivalent of `params.permit(:name, ...)`
* `params!` is just a shortcut to sanitize in mass a list of parameters having the same options
* `group!` is used to sanitize objects or arrays, like `params.permit(my_key: [:list, :of, :keys])`
* `array!` is an alias of `group!` and it's added for readability: in Strong Parameters, `params.permit(name: [:some_key])` accepts both a single object or an array of objects, and this is preserved here.

So the previous example:
```ruby
class PersonParamsSanitizer < Paramoid::Base
  # @param [User] user
  def initialize(user = nil)
    params! :first_name, :last_name

    group! :address_attributes do
      params! :id, :road, :town, :state, :zip_code, :country
    end
  end
end
```

Is equivalent to:
```ruby
params.permit(:first_name, :last_name, address_attributes: [:id, :road, :town, :state, :zip_code, :country])
```

### Required values
Declaring a parameter as required, will raise a `ActionController::ParameterMissing` error if that parameter is not passed by to the controller. This also works with nested structures.

```ruby
class UserParamsSanitizer < Paramoid::Base
  def initialize(user = nil)
    params! :first_name, :last_name, required: true
    group! :contact_attributes do
      param! :phone, required: true
    end
  end
end
```

### Default values
You can declare a default value to a certain parameter. That value is assigned only if that value is not passed in the parameters.

Example:
```ruby
class PostParamsSanitizer < Paramoid::Base
  def initialize(user = nil)
    param! :status, default: 'draft'
    param! :approved, default: false
  end
end
```

Input:
```ruby
<ActionController::Parameters {"status"=>"published","another_parameter"=>"this will be filtered out"} permitted: false>
```

Output:
```ruby
<ActionController::Parameters {"status"=>"published","approved":false} permitted: true>
```

### Name remapping
You can also remap the name of a parameter.
```ruby
class PostParamsSanitizer < Paramoid::Base
  def initialize(user = nil)
    param! :status, as: :state
  end
end
```

Input:
```ruby
<ActionController::Parameters {"status"=>"draft","another_parameter"=>"this will be filtered out"} permitted: false>
```

Output:
```ruby
<ActionController::Parameters {"state"=>"draft"} permitted: true>
```

### Conditional parameters
By using the reference of the current_user in the constructor, you can permit certain parameters based on a specific condition.

Example:
```ruby
class PostParamsSanitizer < Paramoid::Base
  def initialize(user = nil)
    params! :first_name, :last_name
    param! :published if user&.admin?
  end
end
```

### Inline sanitization
You can also use the sanitizer DSL inline directly in your controller:

```ruby
class PeopleController < ApplicationController
  def create
    @person = Person.create!(person_params)
  end

  private

  def person_params
    sanitize_params! do
      params! :first_name, :last_name, required: true
    end
  end
end
```

### Full Example
```ruby
class PersonParamsSanitizer < Paramoid::Base
  # @param [User] user
  def initialize(user = nil)
    params! :first_name, :last_name, :gender

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

## TODOs
* Params type checking and regexp-based validations

About Monade
----------------

![monade](https://monade.io/wp-content/uploads/2021/06/monadelogo.png)

Paramoid is maintained by [mònade srl](https://monade.io/en/home-en/).

We <3 open source software. [Contact us](https://monade.io/en/contact-us/) for your next project!
