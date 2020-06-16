# frozen_string_literal: true

module BeyondCanvas
  module LocaleManagement # :nodoc:
    extend ActiveSupport::Concern

    included do
      around_action :switch_locale, except: :update_locale # rubocop:disable Rails/LexicallyScopedActionFilter
    end

    private

    #
    # Sets the cookie locale as default locale if it is a valid locale. If it is not a valid locale, searches for a
    # browser compatible locale, sets the value to the cookie and set that locale as default locale.
    #
    def switch_locale(&action)
      # NOTE: Check the HTTP_ACCEPT_LANGUAGE header to identify if the request comes from a browser or a server
      return I18n.with_locale(I18n.default_locale, &action) if request.headers['HTTP_ACCEPT_LANGUAGE'].blank?

      unless valid_locale?(cookies[:locale])
        cookies[:locale] = { value: browser_compatible_locale, expires: 1.day.from_now }
      end

      I18n.with_locale(cookies[:locale], &action)

      logger.debug "[BeyondCanvas] Locale set to: #{cookies[:locale]}".yellow
    end

    #
    # Reads the +HTTP_ACCEPT_LANGUAGE+ header and searches a compatible locale
    # on +I18n.available_locales+. If no compatible language is found, it
    # returns +I18n.default_locale+.
    #
    # @return [String] a browser compatible language string or
    #   +I18n.default_locale+. (e.g. +'en-GB'+)
    #
    def browser_compatible_locale
      browser_locales = HTTP::Accept::Languages.parse(request.headers['HTTP_ACCEPT_LANGUAGE'])
      available_locales = HTTP::Accept::Languages::Locales.new(I18n.available_locales.map(&:to_s))

      locales = available_locales & browser_locales

      locales.empty? ? I18n.default_locale : locales.first
    end

    #
    # Checks if the given locale parameter is included on +I18n.available_locales+
    #
    def valid_locale?(locale)
      I18n.available_locales.map(&:to_s).include? locale
    end
  end
end
