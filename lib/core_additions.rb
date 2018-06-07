module CoreAdditions
  module String
    extend ActiveSupport::Concern

    def as_personified_event
      tokens = split('_')
      verb = tokens.first[-1] == 'e' ? "#{tokens.first}r" : "#{tokens.first}er"
      return verb if tokens.size == 1
      what = tokens[1..-1].join('_')
      [what, verb].join('_')
    end
  end
end
