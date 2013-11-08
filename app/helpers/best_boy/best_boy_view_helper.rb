module BestBoy
  module BestBoyViewHelper
    def relative_occurrences(hash, key)
      val = hash[key].to_f
      val = val / hash[:overall].to_f * 100 if hash[:overall].to_i > 0
      number_to_percentage(val, precision: 2)
    end
  end
end
