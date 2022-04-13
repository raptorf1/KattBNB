module DateService
  def self.get_date(number)
    Time.at(number / 1000)
  end

  def self.get_js_epoch()
    now = DateTime.new(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0, 0)
    now_epoch_javascript = (now.to_f * 1000).to_i
    now_epoch_javascript
  end
end
