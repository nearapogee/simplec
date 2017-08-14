class Page::Home < ::Page
  field :tagline
  field :about, type: :text
  field :mission, type: :editor
end
