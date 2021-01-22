# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthorController, type: :controller do
  before do
    @author_controller = AuthorController.new
    allow(@author_controller).to receive(:request).and_return(request)
    allow(@author_controller).to receive(:valid_author?).and_return(true)
  end

  describe @author_controller do
    let(:request) { double(headers: { 'HTTP_REMOTE_USER' => 'authorflow', 'REQUEST_URI' => 'author/index' }) }

    it 'returns 200 response' do
      allow(request).to receive(:env).and_return(:headers)
      expect(response.status).to eq(200)
    end
  end

  # describe 'private' do
  #   let(:request) { double(headers: { 'HTTP_REMOTE_USER' => 'authorflow', 'REQUEST_URI' => '/' }) }
  #   it 'executes a private method' do
  #     allow(request).to receive(:env).and_return(:headers)
  #
  #     expect(@author_controller.send(:find_or_initialize_author)).to render_template('author/index')
  #   end
  # end
end
