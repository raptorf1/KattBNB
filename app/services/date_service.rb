module DateService
  def self.get_date(number)
    Time.at(number / 1000)
  end

  def self.get_js_epoch()
    now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
    now_epoch_javascript = (now.to_f * 1000).to_i
    now_epoch_javascript
  end

  def self.handle_dates_in_stripe_webhook(dates_as_string)
    dates_to_array = dates_as_string.split(",").map(&:to_i)
    if dates_to_array.length == 2 && (dates_to_array.last - dates_to_array.first) != 86_400_000
      booking_dates_stripe_500_limit = []
      start_date = dates_to_array.first.to_i
      stop_date = dates_to_array.last.to_i
      current_date = start_date
      while (current_date <= stop_date)
        booking_dates_stripe_500_limit.push(current_date)
        current_date = current_date + 86_400_000
      end
      return booking_dates_stripe_500_limit
    end
    dates_to_array
  end
end
