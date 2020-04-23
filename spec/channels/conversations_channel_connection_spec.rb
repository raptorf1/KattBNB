RSpec::Benchmark.configure do |config|
  config.run_in_subprocess = true
end

RSpec.describe ApplicationCable::Connection, type: :channel do
  let!(:user1) { FactoryBot.create(:user, email: 'chaos@thestreets.com', nickname: 'Joker', location: 'Athens') }
  let!(:credentials1) { user1.create_new_auth_token }
  let!(:headers1) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials1) }

  it 'successfully connects' do
    connect "/cable/conversation/5?token=#{headers1['access-token']}&uid=#{headers1['uid']}&client=#{headers1['client']}"
    expect(connection.current_user.id).to eq user1.id
  end

  it 'successfully connects under 1 ms' do
    connect_request = connect "/cable/conversation/5?token=#{headers1['access-token']}&uid=#{headers1['uid']}&client=#{headers1['client']}"
    expect { connect_request }.to perform_under(1).ms.sample(20).times
  end

  it 'successfully connects with iteration of at least 5000000 per second' do
    connect_request = connect "/cable/conversation/5?token=#{headers1['access-token']}&uid=#{headers1['uid']}&client=#{headers1['client']}"
    expect { connect_request }.to perform_at_least(5000000).ips
  end

  it 'rejects connection if invalid params are passed' do
    expect { connect "/cable/conversation/5?token=sfbbfjhdjfb&uid=batman@robin.com&client=djfnjkdvjfbfjdfnjgnfkmv" }.to have_rejected_connection
  end

  it 'rejects connection if no params are passed' do
    expect { connect '/cable/conversation/5' }.to have_rejected_connection
  end

end
