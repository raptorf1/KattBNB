module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      if !self.env["QUERY_STRING"].nil?
        params = self.env["QUERY_STRING"]
        uid = params.split("uid=").last.split("&").first
        token = params.split("token=").last.split("&").first
        client_id = params.split("client=").last.split("&").first
        user = User.find_by_uid(uid)
        (user && user.valid_token?(token, client_id)) ? user : reject_unauthorized_connection
      else
        reject_unauthorized_connection
      end
    end
  end
end
