class Message
  include ActiveModel::Model

  attr_accessor :email, :body

  validates :email, presence: true
  validates :body, presence: true

  def initialize(attrs={})
    attrs.each { |attr, val| send("#{attr}=", val) }
  end

  def persisted?
    @_persisted ||= false
  end

  def save
    @_persisted = self.valid?
  end
end
