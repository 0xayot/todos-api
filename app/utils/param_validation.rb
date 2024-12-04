class ParamValidation
  LOGIN_PARAMS = [
    {
      field: :email,
      required: true,
      format: String
    },
    {
      field: :password,
      required: true,
      format: String
    },
  ].freeze

  SIGNUP_PARAMS = [
    {
      field: :email,
      required: true,
      format: String
    },
    {
      field: :password,
      required: true,
      format: String
    },
  ].freeze

  ADDTASK_PARAMS = [
    {
      field: :title,
      required: true,
      format: String
    },
    {
      field: :note,
      required: false,
      format: String
    },
    {
      field: :completed,
      required: false,
      format: :boolean
    },
  ].freeze

  UPDATETASK_PARAMS = [
    {
      field: :id,
      required: true,
      format: String
    },
    {
      field: :title,
      required: false,
      format: String
    },
    {
      field: :note,
      required: false,
      format: String
    },
    {
      field: :completed,
      required: false,
      format: :boolean
    },
  ].freeze
end