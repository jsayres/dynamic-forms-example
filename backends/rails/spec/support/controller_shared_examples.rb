shared_examples "requires an active, logged-in staff or admin user" do |method, action, params|

  let(:auth) { AuthenticationService.new(cookies) }
  let(:params_w_format) { {format: :json}.merge(params || {}) }

  it "should return a 401 error if the user is not logged in" do
    auth.log_out
    send(method, action, params_w_format)
    expect(response.status).to eq 401
  end

  it "should return a 403 error if the user is logged in but not active" do
    auth.log_in(create(:user, active: false, staff: true, admin: true))
    send(method, action, params_w_format)
    expect(response.status).to eq 403
    expect(JSON.parse(response.body).keys).to include('error')
  end

  it "should return a 403 error if the user does not have a staff or admin flag" do
    auth.log_in(create(:user, active: true, staff: false, admin: false))
    send(method, action, params_w_format)
    expect(response.status).to eq 403
    expect(JSON.parse(response.body).keys).to include('error')
  end

end
