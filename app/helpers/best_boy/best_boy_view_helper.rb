module BestBoy
  module BestBoyViewHelper
    def relative_occurrences(source, time_period)
      val = @sourced_occurrences[source][time_period].to_f
      val = val / @sourced_occurrences[source][:overall].to_f * 100 if val > 0
      val
    end
  end
end
