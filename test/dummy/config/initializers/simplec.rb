Simplec::Document.class_eval do
  scope :filter_document_set, ->(document_set=nil) {
    document_set && document_set.persisted? ?
      where(document_set_id: document_set.id) :
      all
  }
end
