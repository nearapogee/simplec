module Simplec
  class Subdomains
    def self.matches?(request)
      simplec = request.headers['HTTP_X_ENGINE'] == 'simplec'
      present = request.subdomain.present?
      not_admin = request.subdomain != 'admin'
      subdomain = Simplec::Subdomain.find_by(name: request.subdomain)

      match = simplec || (present && not_admin && subdomain)

      if match
        Thread.current[:simplec_subdomain] = subdomain
        Rails.logger.info <<-LOG
Simplec request received.
  ActionDispatch::Request#original_url: #{request.original_url}
  Simplec Engine: #{not_admin}
  LOG
      else
        Rails.logger.info <<-LOG
Simplec Subdomain '#{request.subdomain}' was not found.
  ActionDispatch::Request#original_url: #{request.original_url}
  'admin' subdomain bypass: #{!not_admin}
  LOG
      end

      match
    end
  end
end
