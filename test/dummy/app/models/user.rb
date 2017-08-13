class User < ApplicationRecord
  has_secure_password

  class Unauthenticated < StandardError; end
  class Unauthorized < StandardError; end
end
