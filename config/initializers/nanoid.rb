require 'nanoid'

# Configure Nanoid
# The gem doesn't have a configure method, so we'll set up a helper module
module NanoidHelper
  def self.generate(options = {})
    size = options[:size] || 10
    alphabet = options[:alphabet] || '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    Nanoid.generate(size: size, alphabet: alphabet)
  end
end 