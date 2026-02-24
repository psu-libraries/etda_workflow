require 'swagger_helper'

RSpec.describe 'API::V1::CommitteeRecords', type: :request do
  path '/api/v1/committee_records/faculty_committees' do
    post 'Retrieves committee records' do
      tags 'Committee Records'
      produces 'application/json'
      consumes 'application/json'

      description 'Retrieves committee records for a faculty member based on their access ID (PSU)'
      security [BearerAuth: []]

      parameter name: :Authorization,
                in: :header,
                type: :string,
                description: 'Bearer token for authentication',
                required: true

      parameter name: :payload,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  properties: {
                    access_id: { type: :string, example: 'aab27' }
                  },
                  required: ['access_id']
                }
      let!(:external_app) { ExternalApp.create!(name: 'Test App') }
      let!(:api_token) { ApiToken.create!(token: 'test_token', external_app: external_app) }

      response '200', 'committee records retrieved' do
        let(:Authorization) { "Bearer #{api_token.token}" }
        let(:payload) { { access_id: 'aab27' } }

        schema type: :object,
               properties: {
                 committees: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       committee_member_id: { type: :integer },
                       role: { type: :string, nullable: true },
                       role_code: { type: :string, nullable: true },
                       student_fname: { type: :string, nullable: true },
                       student_lname: { type: :string, nullable: true },
                       student_access_id: { type: :string, nullable: true },
                       submission_id: { type: :integer, nullable: true },
                       title: { type: :string, nullable: true },
                       degree_name: { type: :string, nullable: true },
                       program_name: { type: :string, nullable: true },
                       semester: { type: :string, nullable: true },
                       year: { type: :integer, nullable: true },
                       approval_started_at: { type: :string, format: 'date-time', nullable: true },
                       final_submission_approved_at: { type: :string, format: 'date-time', nullable: true },
                       submission_status: { type: :string, nullable: true },
                       committee_member_status: { type: :string, nullable: true }
                     }
                   }
                 }
               },
               required: ['faculty_access_id', 'committees']

        run_test!
      end

      response '400', 'access_id missing' do
        let(:Authorization) { "Bearer #{api_token.token}" }
        let(:payload) { {} }

        schema type: :object,
               properties: { error: { type: :string } },
               required: ['error']

        run_test! do |response|
          expect(JSON.parse(response.body)['error']).to eq('access_id is required')
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }
        let(:payload) { { access_id: 'aab27' } }

        schema type: :object,
               properties: { error: { type: :string } },
               required: ['error']

        run_test! do |response|
          expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
        end
      end

      response '400', 'bad request - missing access_id' do
        let(:x_api_key) { 'valid_api_key' }
        let(:payload) { {} }

        run_test! do |response|
          expect(response.body).to include('access_id')
        end
      end
    end
  end
end
