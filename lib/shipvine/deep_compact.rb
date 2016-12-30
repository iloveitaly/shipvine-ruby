# https://github.com/infochimps-labs/gorillib/blob/cd88bed1cba29c31f27dcce90bddbcbfbca33487/lib/gorillib/array/deep_compact.rb

class Hash
  def deep_compact!
    each_pair do |key, val|
      val.deep_compact! if val.respond_to?(:deep_compact!)
      delete(key) if val.blank?
    end
    self
  end
end

class Array
  #
  # deep_compact! removes all 'blank?' elements in the array in place, recursively
  #
  def deep_compact!
    self.map! do |val|
      val.deep_compact! if val.respond_to?(:deep_compact!)
      val unless val.blank?
    end.compact!
  end
end
