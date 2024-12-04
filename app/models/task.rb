class Task < ApplicationRecord
  validates_presence_of :title

  belongs_to :user

  def json_attributes
    {
      id: id,
      title: title,
      completed: completed,
      note: note,
      created_at: created_at
    }
  end

  def as_json(options = {})
    json_attributes
  end
end
