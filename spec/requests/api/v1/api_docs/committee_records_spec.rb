require 'swagger_helper'

RSpec.describe 'API::V1::CommitteeRecords', type: :request do
  let!(:external_app) { ExternalApp.create!(name: "Test App") }
  let!(:api_token) { ApiToken.create!(token: "test_token", external_app: external_app) }

  path '/api/v1/committee_records/faculty_committees' do
    post 'Retrieves committee records' do
      tags 'Committee Records'
      produces 'application/json'
      consumes 'application/json'

      description 'Retrieves committee records for a faculty member based on their access ID (PSU)'
      security [ApiKeyAuth: []]

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
        let(:'X-API-KEY') { external_app.token }
        let(:payload) { { access_id: 'aab27' } }

        schema type: :object,
               properties: {
                 committees: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       committee_member_id: { type: :integer, example: 789 },
                       role: { type: :string, nullable: true, example: 'Director' },
                       role_code: { type: :string, nullable: true, example: 'DI' },
                       student_fname: { type: :string, nullable: true, example: 'Muhammad' },
                       student_lname: { type: :string, nullable: true, example: 'Siddiqui' },
                       student_access_id: { type: :string, nullable: true, example: 'ums467' },
                       submission_id: { type: :integer, nullable: true, example: 43 },
                       title: { type: :string, nullable: true, example: 'SPIDERMAN' },
                       degree_type: { type: :string, nullable: true, example: 'Dissertation' },
                       degree_name: { type: :string, nullable: true, example: 'PhD' },
                       program_name: { type: :string, nullable: true, example: 'Computer science' },
                       semester: { type: :string, nullable: true, example: 'Fall' },
                       year: { type: :integer, nullable: true, example: 2028 },
                       approval_started_at: { type: :string, format: 'date-time', nullable: true, example: Time.zone.now },
                       final_submission_approved_at: { type: :string, format: 'date-time', nullable: true, example: Time.zone.now },
                       submission_status: { type: :string, nullable: true, example: 'released for publication' },
                       committee_member_status: { type: :string, nullable: true, example: 'approved' }
                     }
                   }
                 }
               },
               required: ['faculty_access_id', 'committees']

        run_test!
      end

      response '400', 'access_id missing' do
        let(:'X-API-KEY') { external_app.token }
        let(:payload) { {} }

        schema type: :object,
               properties: { error: { type: :string, example: 'access_id is required' } },
               required: ['error']

        run_test! do |response|
          expect(JSON.parse(response.body)['error']).to eq('access_id is required')
        end
      end

      response '401', 'unauthorized' do
        let(:'X-API-KEY') { nil }
        let(:payload) { { access_id: 'aab27' } }

        schema type: :object,
               properties: { error: { type: :string, example: 'Unauthorized' } },
               required: ['error']

        run_test! do |response|
          expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
        end
      end
    end
  end
end
