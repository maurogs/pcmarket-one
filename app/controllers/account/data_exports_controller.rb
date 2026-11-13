# GDPR art. 20 data portability.
class Account::DataExportsController < Account::BaseController
  def show
    send_data UserDataExport.new(current_user).to_json, filename: "#{current_user.username}-data-#{Date.current}.json",
                                                        type: "application/json"
  end
end
