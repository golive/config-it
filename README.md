config-it
=========

It has to be something like this

```ruby
  class Settings
  
    settings column: 'config' do
      key :users do
        key :mails_for_errors do
          validates_presence
          before_save do |value|
            value.split(/\s*,\s*/)
          end
          default ['a@mail.es']
        end
        key :mails_for_warinings, type: :array, default: User.first.email
        key :max_logins do
          validates_length in: 10..20
          default 6
        end
      end
    end
  end
```
