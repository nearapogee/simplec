module Simplec
  module Admin
    class Page < Simplec::Page
      # ignore type column for instatiation in admin pages,
      # which can cause errors if a model class is deleted
      self.inheritance_column = nil
    end
  end
end

