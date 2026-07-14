# frozen_string_literal: true

RSpec.shared_context 'session double', shared_context: :metadata do
  let(:session_hash) { {} }
  let(:session_double) { instance_double(ActionDispatch::Request::Session, enabled?: true, loaded?: false) }

  before do
    allow(session_double).to receive(:[]) do |key|
      session_hash[key]
    end

    allow(session_double).to receive(:[]=) do |key, value|
      session_hash[key] = value
    end

    allow(session_double).to receive(:delete) do |key|
      session_hash.delete(key)
    end

    allow(session_double).to receive(:clear) do |_key|
      session_hash.clear
    end

    allow(session_double).to receive(:fetch) do |key|
      session_hash.fetch(key)
    end

    allow(session_double).to receive(:key?) do |key|
      session_hash.key?(key)
    end

    allow_any_instance_of(ActionDispatch::Request)
      .to receive(:session).and_return(session_double)
  end
end

RSpec.configure do |rspec|
  rspec.include_context "session double", include_shared: true
end
