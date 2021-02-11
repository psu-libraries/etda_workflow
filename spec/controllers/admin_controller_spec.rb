require 'rails_helper'

RSpec.describe AdminController, type: :controller do
  before do
    @admin_controller = AdminController.new
    allow(@admin_controller).to receive(:request).and_return(request)
  end

  describe 'admin_controller' do
    let(:request) { double(headers: { 'HTTP_REMOTE_USER' => 'adminflow', 'REQUEST_URI' => 'admin/index' }) }

    it 'returns 200 response' do
      allow(request).to receive(:env).and_return(:headers)
      # allow_any_instance_of(current_admin).to receive(:access_id).and_return('adminflow')
      expect(response.status).to eq(200)
    end
  end
end
