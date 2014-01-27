unless String.method_defined? :classify
  class String
    def classify
      self.split(/_/).map(&:capitalize).join
    end
  end
end
