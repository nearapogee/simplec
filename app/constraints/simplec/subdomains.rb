module Simplec
  class Subdomains
		def self.matches?(request)
      present = request.subdomain.present?
		  not_admin = request.subdomain != 'admin'
	    subdomain = Simplec::Subdomain.find_by(name: request.subdomain)

			match = present && not_admin && subdomain

      if match
        Thread.current[:simplec_subdomain] = subdomain
      else
        Rails.logger.info <<-LOG unless match
Simplec Subdomain '#{request.subdomain}' was not found.
  ActionDispatch::Request#original_url: #{request.original_url}
  'admin' subdomain bypass: #{!not_admin}
LOG
      end

			match
		end
  end
end
