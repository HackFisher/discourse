# encoding: utf-8

module Slug

  def self.for(string, default = 'topic')
    slug = case (SiteSetting.slug_generation_method || :ascii).to_sym
           when :ascii then self.ascii_generator(string)
           when :encoded then self.encoded_generator(string)
           when :none then self.none_generator(string)
           end
    # Reject slugs that only contain numbers, because they would be indistinguishable from id's.
    slug = (slug =~ /[^\d]/ ? slug : '')
    slug.blank? ? default : slug
  end

  def self.sanitize(string)
    self.encoded_generator(string)
  end

  private

  def self.ascii_generator(string)
    # TODO review if ja should use this
    # ko asked for it to be removed
    if ['zh_CN', 'ja'].include?(SiteSetting.default_locale)
      unless defined? Stringex
        require 'stringex_lite'
      end
      slug = string.to_url
    else
      slug = string.gsub("'", "").parameterize
      slug.gsub!("_", "-")
    end    +
    slug =~ /[^\d]/ ? slug : '' # Reject slugs that only contain numbers, because they would be indistinguishable from id's.
  end

  def self.encoded_generator(string)
    # This generator will sanitize almost all special characters,
    # including reserved characters from RFC3986.
    # See also URI::REGEXP::PATTERN.
    string.strip
          .gsub(/\s+/, '-')
          .gsub(/[:\/\?#\[\]@!\$&'\(\)\*\+,;=_\.~%\\`^\s|\{\}"<>]+/, '') # :/?#[]@!$&'()*+,;=_.~%\`^|{}"<>
          .gsub(/\A-+|-+\z/, '') # remove possible trailing and preceding dashes
          .squeeze('-') # squeeze continuous dashes to prettify slug
  end

  def self.none_generator(string)
    ''
  end
end
