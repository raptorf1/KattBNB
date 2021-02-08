module ResponseJSON
  def json_response
    JSON.parse(response.body)
  end
end

RSpec.configure { |config| config.include ResponseJSON }
