# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExtensionController, type: :controller do
  describe '#autorelease_extension' do
    let!(:submission) { FactoryBot.create :submission, extension_token: '12345' }

    it 'routes to extension/[:extension_token]' do
      expect(get: autorelease_extension_path(submission.extension_token)).to route_to(controller: 'extension', action: 'autorelease_extension', extension_token: submission.extension_token)
    end
  end
end
