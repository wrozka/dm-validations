# encoding: UTF-8

module DataMapper
  module Validations
    module Format
      module Email

        def self.included(base)
          DataMapper::Validations::FormatValidator::FORMATS.merge!(
            :email_address => [ EmailAddress, lambda { |field, value| '%s is not a valid email address'.t(value) }]
          )
        end

        # Almost RFC2822 (No attribution reference available).
        #
        # This differs in that it does not allow local domains (test@localhost).
        # 99% of the time you do not want to allow these email addresses
        # in a public web application.
        EmailAddress = begin
            if RUBY_VERSION == '1.9.2' && RUBY_ENGINE == 'jruby'
              # There is an obscure bug in jruby 1.6 that prevents matching
              # on unicode properties here. We can revert the commit that
              # added this comment when it is fixed.
              #
              # http://jira.codehaus.org/browse/JRUBY-5622
              alpha = "a-zA-Z"
            else
              alpha = "a-zA-Z\\p{L}" # Changed from RFC2822 to include unicode chars
            end
            digit = "0-9"
            atext = "[#{alpha}#{digit}\!\#\$\%\&\'\*+\/\=\?\^\_\`\{\|\}\~\-]"
            dot_atom_text = "#{atext}+([.]#{atext}*)+" # Last char changed from * to +
            dot_atom = "#{dot_atom_text}"
            no_ws_ctl = "\\x01-\\x08\\x11\\x12\\x14-\\x1f\\x7f"
            qtext = "[^#{no_ws_ctl}\\x0d\\x22\\x5c]" # Non-whitespace, non-control character except for \ and "
            text = "[\\x01-\\x09\\x11\\x12\\x14-\\x7f]"
            quoted_pair = "(\\x5c#{text})"
            qcontent = "(?:#{qtext}|#{quoted_pair})"
            quoted_string = "[\"]#{qcontent}+[\"]"
            atom = "#{atext}+"
            word = "(?:#{atom}|#{quoted_string})"
            obs_local_part = "#{word}([.]#{word})*"
            local_part = "(?:#{dot_atom}|#{quoted_string}|#{obs_local_part})"
            dtext = "[#{no_ws_ctl}\\x21-\\x5a\\x5e-\\x7e]"
            dcontent = "(?:#{dtext}|#{quoted_pair})"
            domain_literal = "\\[#{dcontent}+\\]"
            obs_domain = "#{atom}([.]#{atom})+" # Last char changed from * to +
            domain = "(?:#{dot_atom}|#{domain_literal}|#{obs_domain})"
            addr_spec = "#{local_part}\@#{domain}"
            pattern = /^#{addr_spec}$/u
        end

      end # module Email
    end # module Format
  end # module Validations
end # module DataMapper
