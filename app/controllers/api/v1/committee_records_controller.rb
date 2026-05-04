module Api
  module V1
    class CommitteeRecordsController < ApplicationController
      skip_before_action :verify_authenticity_token

      before_action :authenticate_api_key

      def faculty_committees
        access_id = params[:access_id]
        if access_id.blank?
          render json: { error: 'access_id is required' }, status: :bad_request
          return
        end

        committee_memberships = CommitteeMember
                                .joins(:submission).where('submissions.status LIKE "released for publication%" OR submissions.status = "waiting for publication release"')
                                .includes(:committee_role, submission: [:author, :degree, :program])
                                .where(access_id: access_id)

        render json: {
          faculty_access_id: access_id,
          committees: format_committees(committee_memberships)
        }, status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      private

        def authenticate_api_key
          token = request.headers['HTTP_X_API_KEY']

          @api_token = ApiToken.includes(:external_app).find_by(token: token)
          return unauthorized! unless @api_token

          @external_app = @api_token.external_app
          @api_token.update_column(:last_used_at, Time.current)

          true
        end

        def unauthorized!
          render json: { error: "Unauthorized" }, status: :unauthorized
        end

        def format_committees(committee_memberships)
          committee_memberships.map { |membership| committee_payload(membership) }
        end

        def committee_payload(membership)
          submission = membership.submission
          author = submission&.author

          {
            committee_member_id: membership.id,

            role: membership.committee_role&.name,
            role_code: membership.committee_role&.code,

            student_fname: author&.first_name,
            student_lname: author&.last_name,
            student_access_id: author&.access_id,

            submission_id: submission.id,
            title: submission.title,
            degree_type: submission.degree_type&.name,
            degree_name: submission.degree&.name,
            program_name: submission.program&.name,
            semester: submission.semester,
            year: submission.year,

            approval_started_at: membership.approval_started_at,
            final_submission_approved_at: submission.final_submission_approved_at,

            submission_status: submission.status,
            committee_member_status: membership.status
          }
        end
    end
  end
end
