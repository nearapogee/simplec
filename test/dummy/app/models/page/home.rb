class Page::Home < ::Page
  field :tagline
  field :about, type: :text
  field :mission, type: :editor
  field :logo, type: :image
  field :worksheet, type: :file
end
