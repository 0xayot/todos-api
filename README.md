### Getting Started

- Install all dependencies `bundle install`

- Setup your database

  ```
    rails db:create

    rails db:migrate

    rails db:create RAILS_ENV=test

    rails db:migrate RAILS_ENV=test
  ```

### Tradeoffs and Decisions

I am assumming this is a new project from scratch so I can decide how to structure it. Some decisions were made to allow me finish in the alloted time and as such improvements will be outlined for these tradeoffs.

- I changed the password field from `password_digest` to `encrypted_password` to support Devise. I like to stick to the conventions of gems when I can.
  You can use the code below to use the initial setup.

```
  def encrypted_password
    self.password_digest
  end

  def encrypted_password=(new_password)
    self.password_digest = new_password.blank? ? nil : Devise::Encryptor.digest(self, new_password)
  end

  <!--  -->
  class << self
    def pepper
      nil
    end
  end
```

-

### Possible Improvements

- Update the ruby, bundle and rails versions to a current and supported version. There are a bunch of Deprecation warnings and anti patterns that were allowed because we want to support the version the project.
- We can add a user serializer that generates the the json outputs for user objects. See the example below.
- We can choose to use regex to properly validate the inputs for emails e.t.c
- We can also choose to use redis to cache user and task values.
- Configuring APM software (Sentry, Datadog) to keep logs.

## Routes

- ## Users

  - `POST /Users`

    ```request
      {
        "email": "teowast@gmail.com",
        "password": "abc123ABC!@#"
      }
    ```

    ```
      {
        "user": {
          "id": 12,
          "email": "teowast@gmail.com",
          "created_at": "2024-12-04T23:05:45.493Z"
        }
      }
    ```

  - `POST /login`
    ```request
    {
    "email": "teowast@gmail.com",
    "password": "abc123ABC!@#"
    }

    ````

    ``` 200 ok
      {
        "token": "some-token
      }
    ````

  - `GET /current_user` `Authenticated`

  Headers

  ```
    {
      "Authorization": "Bearer token-from-login"
    }
  ```

  ```
    {
      "user": {
        "id": 12,
        "email": "teowast@gmail.com",
        "created_at": "2024-12-04T23:05:45.493Z"
      }
    }
  ```

- ## Tasks `Authenticated`

  - `GET /tasks?completed=false&limit=3&page=2`

  ```
    {
      "tasks": [
            {
          "id": 3,
          "title": "note 3",
          "completed": false,
          "note": "we want to edit some other",
          "created_at": "2024-12-04T12:55:24.721Z"
        },
      ]
      "pagination": {
        "current_page": 1,
        "total_pages": 1,
        "total_count": 5,
        "limit": 25
      }
    }
  ```

  - `GET /tasks/:id`

  ```
    {
      "tasks": {
        "id": 3,
        "title": "note 3",
        "completed": false,
        "note": "we want to edit some other",
        "created_at": "2024-12-04T12:55:24.721Z"
      }
    }
  ```

  - `POST /tasks/:id`

  ```Request
    {
      "title": "note 3",
      "note": "we won"
      "completed": true #optional
    }
  ```

  ```
    {
      "tasks": {
        "id": 3,
        "title": "note 3",
        "completed": false,
        "note": "we want to edit some other",
        "created_at": "2024-12-04T12:55:24.721Z"
      }
    }
  ```

  - `PUT /tasks/:id`

  ```Request
    {
      "title": "note 3",
      "note": "we want to edit some other"  #optional
      "completed": true #optional
    }
  ```

  ```
    {
      "tasks": {
        "id": 3,
        "title": "note 3",
        "completed": false,
        "note": "we want to edit some other",
        "created_at": "2024-12-04T12:55:24.721Z"
      }
    }
  ```
