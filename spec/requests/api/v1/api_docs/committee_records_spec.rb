RSpec.describe 'API::V1::CommitteeRecords' do
  path '/api/v1/committee_records' do
    post 'Retrieves committee records' do
      tags 'Committee Records'
      produces 'application/json'
      consumes 'application/json'

      description 'Retrieves committee records for a faculty member based on their access ID (PSU)'
      security [Bearer: []]

      response '200', 'committee records retrieved' do
        schema type: :object,
               properties: {
                 committee_records: {
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
               required: ['committee_records']

        let(:Authorization) { "Bearer valid_api_token" }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_api_token' }

        run_test!
      end
    end
  end
end
