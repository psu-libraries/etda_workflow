class Lionpath::LionpathDeleteExpiredRecords
  class << self
    def delete
      if safe_to_delete?(total_lp_sub_count, lp_subs_to_delete.count)
        lp_subs_to_delete.each(&:destroy)
      else
        Bugsnag.notify(I18n.t('graduate.partner.lionpath_alert',
                              resource: 'Submissions',
                              datetime_now: DateTime.now))
      end
      if safe_to_delete?(total_lp_cmtee_mmbr_count, lp_cmtee_mmbrs_to_delete.count)
        lp_cmtee_mmbrs_to_delete.each(&:destroy)
      else
        Bugsnag.notify(I18n.t('graduate.partner.lionpath_alert',
                              resource: 'Committee Members',
                              datetime_now: DateTime.now))
      end
    end

    private

      def total_lp_subs
        Submission
          .where('submissions.lionpath_updated_at IS NOT NULL AND submissions.created_at > ?',
                 (DateTime.now - 5.years))
      end

      def total_lp_cmtee_mmbrs
        CommitteeMember
          .where('committee_members.lionpath_updated_at IS NOT NULL AND committee_members.created_at > ?',
                 (DateTime.now - 5.years))
      end

      def total_lp_sub_count
        total_lp_subs.count
      end

      def total_lp_cmtee_mmbr_count
        total_lp_cmtee_mmbrs.count
      end

      def lp_subs_to_delete
        total_lp_subs.where('submissions.lionpath_updated_at < ? AND submissions.status = "collecting program information"',
                            (DateTime.now - 2.days))
      end

      # External to PSU committee members will stop updating after they are imported.
      # Program Heads are no longer being imported, but there are legacy LP Program Heads.
      # Committee members for submissions beyond final submission response rejected stop importing
      # Therefore, they all need to be excluded from the following query.
      def lp_cmtee_mmbrs_to_delete
        total_lp_cmtee_mmbrs
          .joins(:committee_role)
          .where('committee_members.external_to_psu_id IS NULL AND committee_members.lionpath_updated_at < ?',
                 (DateTime.now - 2.days))
          .where('committee_roles.is_program_head != true')
          .select { |cm| cm unless cm.submission.status_behavior.beyond_waiting_for_final_submission_response_rejected? }
      end

      def safe_to_delete?(total_num, num_to_delete)
        (num_to_delete / total_num.to_f) < (10 / 100.to_f)
      end
  end
end
