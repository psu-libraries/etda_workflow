module Api
  module V1
    class CommitteeRecordsController < ApplicationController
      # Skip CSRF token verification for API requests
      skip_before_action :verify_authenticity_token

      # Authentication filter
      before_action :authenticate_api_key

      # POST /api/v1/committee_records/faculty_committees
      # Expected params: { access_id: "xyz123" }
      # Returns: JSON with all committee memberships for the faculty member
      #
      # Example request:
      #   curl -X POST http://localhost:3000/api/v1/committee_records/faculty_committees \
      #     -H "Content-Type: application/json" \
      #     -H "Authorization: your-api-key" \
      #     -d '{"access_id": "abc123"}'
      #
      def faculty_committees
        access_id = params[:access_id]

        # Validate required parameter
        if access_id.blank?
          render json: { error: 'access_id is required' }, status: :bad_request
          return
        end

        # Find all committee memberships for this faculty member
        # Note: We search by access_id which is the PSU ID
        committee_memberships = CommitteeMember
                                .includes(submission: [:author, :degree, :program], committee_role: [])
                                .where(access_id: access_id)

        # Format the response
        response_data = {
          faculty_access_id: access_id,
          committees: format_committees(committee_memberships)
        }

        render json: response_data, status: :ok
      end

      private

      # Authenticate using API Key from environment variable
      # The API Key should be passed in the Authorization header
      def authenticate_api_key
        provided_key = request.headers['Authorization']
        expected_key = ENV['COMMITTEE_API_KEY']

        return if provided_key.present? && provided_key == expected_key

        render json: { error: 'Unauthorized' }, status: :unauthorized
      end

      # Format committee memberships for Activity Insight
      # Returns an array of committee membership objects
      def format_committees(committee_memberships)
        committee_memberships.map do |membership|
          submission = membership.submission

          # Build the committee data object
          {
            # Committee member info
            committee_member_id: membership.id,
            faculty_name: membership.name,
            faculty_email: membership.email,
            faculty_access_id: membership.access_id,

            # Committee role
            role: membership.committee_role&.name,
            role_code: membership.committee_role&.code,

            # Student information
            student_name: submission.author&.name || "Unknown",
            student_access_id: submission.author&.access_id,

            # Submission information
            submission_id: submission.id,
            title: submission.title,
            degree_name: submission.degree&.name,
            program_name: submission.program&.name,
            semester: submission.semester,
            year: submission.year,

            # Important dates
            defended_at: submission.defended_at,
            committee_provided_at: submission.committee_provided_at,
            final_submission_approved_at: submission.final_submission_approved_at,

            # Status information
            submission_status: submission.status,
            committee_member_status: membership.status,
            approved_at: membership.approved_at,
            rejected_at: membership.rejected_at,

            # Additional metadata
            is_required: membership.is_required,
            is_voting: membership.is_voting,
            federal_funding_used: membership.federal_funding_used
          }
        end
      end
    end
  end
end
