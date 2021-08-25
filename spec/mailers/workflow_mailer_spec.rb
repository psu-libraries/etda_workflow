require 'model_spec_helper'

RSpec.describe WorkflowMailer do
  let(:submission) { FactoryBot.create :submission }
  let(:committee_member) { FactoryBot.create :committee_member, submission: submission }
  let(:access_updated_email) do
    {
      author_alternate_email_address: "author alt address",
      cc_email_addresses: ["cc's"]
    }
  end
  let(:author) { submission.author }
  let(:partner_email) { current_partner.email_address }
  let(:verify_files_results) { "Misplaced files found." }

  describe '#format_review_received' do
    before { allow(Partner).to receive(:current).and_return(partner) }

    let(:email) { described_class.format_review_received(submission) }
    let(:partner_email) { partner.email_address }

    context "when the current partner is 'graduate'" do
      let(:partner) { Partner.new('graduate') }

      it "sets an appropriate subject" do
        expect(email.subject).to match(/format review has been received/i)
      end

      it "is sent from the partner support email address" do
        expect(partner_email).not_to match(/missing/i)
        expect(email.from).to eq([partner_email])
      end

      it "is sent to the student's PSU email address" do
        expect(author.psu_email_address).not_to be_blank
        expect(email.to).to eq([author.psu_email_address])
      end

      it "tells them that their format review has been received" do
        expect(email.body).to match(/will be in touch/i)
      end
    end

    context "when the current partner is 'honors'" do
      let(:partner) { Partner.new('honors') }

      xit "raises an exception" do
        expect { email.deliver_now }.to raise_error ActionView::Template::Error
      end
    end
  end

  describe '#format_review_accepted' do
    let(:email) { described_class.format_review_accepted(submission) }
    let(:partner_email) { current_partner.email_address }

    context "when the current partner is 'sset'", sset: true do
      before do
        skip 'sset only' unless current_partner.sset?
      end

      it "sets an appropriate subject" do
        expect(email.subject).to match(/format review has been accepted/i)
      end

      it "is sent from the partner support email address" do
        expect(email.from).to eq([partner_email])
      end

      it "is sent to the student's PSU email address" do
        expect(author.psu_email_address).not_to be_blank
        expect(email.to).to eq([author.psu_email_address])
      end

      it "tells them that their format review has been accepted" do
        expect(email.body).to match(/has been approved by administrators/i)
      end
    end

    context "when the current partner is not 'sset'" do
      it "raises an exception" do
        skip 'non sset only' if current_partner.sset?

        expect { email.deliver_now }.to raise_error WorkflowMailer::InvalidPartner
      end
    end
  end

  describe '#format_review_rejected' do
    let(:email) { described_class.format_review_rejected(submission) }
    let(:partner_email) { current_partner.email_address }

    context "when the current partner is 'sset'", sset: true do
      before do
        skip 'sset only' unless current_partner.sset?
      end

      it "sets an appropriate subject" do
        expect(email.subject).to match(/format review has been rejected/i)
      end

      it "is sent from the partner support email address" do
        expect(email.from).to eq([partner_email])
      end

      it "is sent to the student's PSU email address" do
        expect(author.psu_email_address).not_to be_blank
        expect(email.to).to eq([author.psu_email_address])
      end

      it "tells them that their format review has been rejected" do
        expect(email.body).to match(/Project Paper has been rejected/i)
      end
    end

    context "when the current partner is not 'sset'" do
      it "raises an exception" do
        skip 'non sset only' if current_partner.sset?

        expect { email.deliver_now }.to raise_error WorkflowMailer::InvalidPartner
      end
    end
  end

  describe '#final_submission_received' do
    before { allow(Partner).to receive(:current).and_return(partner) }

    let(:email) { described_class.final_submission_received(submission) }
    let(:partner_email) { partner.email_address }

    context "when the current partner is 'graduate'" do
      let(:partner) { Partner.new('graduate') }

      it "sets an appropriate subject" do
        expect(email.subject).to match(/has been received/i)
      end

      it "is sent from the partner support email address" do
        expect(partner_email).not_to match(/missing/i)
        expect(email.from).to eq([partner_email])
      end

      it "is sent to the student's PSU email address" do
        expect(author.psu_email_address).not_to be_blank
        expect(email.to).to eq([author.psu_email_address])
      end

      it "tells them that their final submission has been received" do
        expect(email.body).to match(/Thank you for submitting/i)
      end
    end

    context "when the current partner is 'honors'" do
      let(:partner) { Partner.new('honors') }

      xit "raises an exception" do
        expect { email.deliver_now }.to raise_error ActionView::Template::Error
      end
    end
  end

  describe '#final_submission_approved' do
    let(:email) { described_class.final_submission_approved(submission) }

    it "sets an appropriate subject" do
      expect(email.subject).to match(/has been approved/i)
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "is sent to the student's PSU email address" do
      expect(email.to).to eq([author.psu_email_address])
    end

    it "tells the author that the final submission has been approved" do
      expect(email.body).to match(/Congratulations!|has been approved/i)
    end
  end

  describe '#release_for_publication' do
    let(:email) { described_class.release_for_publication(submission) }

    it "sets an appropriate subject" do
      expect(email.subject).to match(/has been released/i)
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "is sent to the student's PSU email address" do
      expect(email.to).to eq([author.psu_email_address, author.alternate_email_address])
    end

    it "tells the author that the submission has been released" do
      expect(email.body).to match(/has been released with the access level of Open Access/i)
    end
  end

  describe '#release_for_publication_metadata_only' do
    let(:email) { described_class.release_for_publication_metadata_only(submission) }

    it "sets an appropriate subject" do
      expect(email.subject).to match(/metadata has been released/i)
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "is sent to the student's PSU email address" do
      expect(email.to).to eq([author.psu_email_address, author.alternate_email_address])
    end

    it "tells the author that the submission's metadata is released" do
      expect(email.body).to match(/It retains its access level of/i)
    end
  end

  describe '#sent_to_committee' do
    let(:email) { described_class.sent_to_committee(submission) }

    it "sets an appropriate subject" do
      expect(email.subject).to eq "Committee Review Initiated"
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "is sent to the student's PSU email address" do
      expect(email.to).to eq([author.psu_email_address])
    end

    it "tells the author that the final submission has been sent back to the committee" do
      expect(email.body).to match(/#{submission.degree_type}: "#{submission.title}" has been sent/i)
    end
  end

  describe '#committee_approved' do
    let(:email) { described_class.committee_approved(submission) }

    before do
      submission.committee_members << committee_member
    end

    it "sets an appropriate subject" do
      expect(email.subject).to match(/has been approved by committee/i)
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "is sent to the student's PSU email address" do
      expect(email.to).to eq([author.psu_email_address])
    end

    it "is cc'd to committee and partner email" do
      expect(email.cc).to eq([submission.committee_email_list, current_partner.email_address].flatten)
    end

    it "tells the author that the final submission has been approved" do
      expect(email.body).to match(/committee and it is approved/i)
    end
  end

  describe '#committee_rejected_author' do
    let(:email) { described_class.committee_rejected_author(submission) }
    before do
      create_committee submission
    end

    it "sets an appropriate subject" do
      expect(email.subject).to eq "Committee Rejected Final Submission"
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "is sent to proper recipients depending on partner", honors: true, sset: true, milsch: true do
      expect(email.to).to eq([current_partner.email_list]) if current_partner.graduate?
      expect(email.to).to eq([author.psu_email_address]) unless current_partner.graduate?
    end

    it "tells the author that the final submission has been approved" do
    end
  end

  describe '#committee_rejected_admin' do
    let(:email) { described_class.committee_rejected_admin(submission) }

    it "sets an appropriate subject" do
      expect(email.subject).to eq "Committee Rejected Final Submission"
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "is sent to the student's PSU email address" do
      expect(email.to).to eq([current_partner.email_list])
    end

    it "tells the author that the final submission has been approved" do
      expect(email.body).to match(/has rejected their submission/i)
    end
  end

  describe '#committee_rejected_committee' do
    let(:email) { described_class.committee_rejected_admin(submission) }

    it "sets an appropriate subject" do
      expect(email.subject).to eq "Committee Rejected Final Submission"
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "is sent to the student's PSU email address" do
      expect(email.to).to eq([current_partner.email_list])
    end

    it "tells the author that the final submission has been approved" do
      expect(email.body).to match(/has rejected their submission/i)
    end
  end

  describe '#access_level_updated' do
    let(:email) { described_class.access_level_updated(access_updated_email) }

    it "sets an appropriate subject" do
      expect(email.subject).to match(/access level for your submission has been updated/i)
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "is sent to the student's Alternate email address" do
      expect(email.to).to eq("author alt address")
    end

    it "is carbon copied to the " do
      expect(email.cc).to eq(["cc's"])
    end

    it "notifies the author about the access level change of their submission" do
      expect(email.body).to match(/changed the availability/i)
    end
  end

  describe '#open_access_report' do
    let(:date_range) { "#{(Date.today - 6.months).strftime('%D')} - #{Date.today.strftime('%D')}" }
    let(:csv) { CSV.generate { |csv| csv << ['HEADERS'] } }
    let(:email) { described_class.semester_release_report(date_range, csv, "filename.csv") }

    it "sets an appropriate subject" do
      expect(email.subject).to eq "eTDs Released Between #{date_range}"
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "has csv attachment" do
      expect(email.attachments.first.filename).to eq("filename.csv")
    end

    it "contains information about publications released as open access this semester" do
      expect(email.parts.first.body.to_s).to match(/were released between #{date_range}/i)
      expect(email.parts.first.body.to_s).to match(/#{current_partner.name}/i)
    end
  end

  describe '#verify_files_email' do
    let(:email) { described_class.verify_files_email(verify_files_results) }

    it "is sent from ajk5603@psu.edu" do
      expect(email.from).to eq(["ajk5603@psu.edu"])
    end

    it "is sent to ajk5603@psu.edu" do
      expect(email.to).to eq(["ajk5603@psu.edu"])
    end

    it "has subject" do
      expect(email.subject).to eq("VERIFY FILES: Misplaced files found")
    end

    it "has body" do
      expect(email.body.raw_source).to eq("Verify Files\r\n\r\nMisplaced files found.")
    end
  end

  describe '#lionpath_deletion_alert', milsch: true, honors: true, sset: true do
    let(:email) { described_class.lionpath_deletion_alert('Submissions') }

    context 'when current_partner is graduate' do
      before do
        skip 'graduate only' unless current_partner.graduate?
      end

      context "when 'resource' parameter is 'Submissions'" do
        it "is sent from partner email" do
          expect(email.from).to eq([partner_email])
        end

        it "is sent to dev lead email" do
          expect(email.to).to eq([I18n.t('devs.lead.primary_email_address')])
        end

        it "has subject" do
          expect(email.subject).to eq("Alert: LionPATH Deletion Exceeded 10%")
        end

        it "has body" do
          expect(email.body.raw_source).to match(/More than 10% of LionPATH Submissions were tagged/)
        end
      end

      context "when 'resource' parameter is 'Committee Members'" do
        let(:email) { described_class.lionpath_deletion_alert('Committee Members') }

        it "has body" do
          expect(email.body.raw_source).to match(/More than 10% of LionPATH Committee Members were tagged/)
        end
      end
    end

    context 'when current_partner is not graduate' do
      before do
        skip 'non graduate only' if current_partner.graduate?
      end

      it 'raises an error' do
        expect { email.deliver }.to raise_error WorkflowMailer::InvalidPartner
      end
    end
  end

  describe '#pending_returned_author' do
    let(:email) { described_class.pending_returned_author(submission) }

    it "is sent to the proper recipient" do
      expect(email.to).to eq([submission.author.psu_email_address])
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "sets an appropriate subject" do
      expect(email.subject).to eq("Final Submission Returned for Resubmission")
    end

    it "has desired content" do
      expect(email.body).to match(/has been rejected by request of an administrator/)
    end
  end

  describe '#pending_returned_committee' do
    let(:email) { described_class.pending_returned_committee(submission) }
    let(:cm_role) { FactoryBot.create :committee_role, is_program_head: true }
    let(:cm1) { FactoryBot.create :committee_member }
    let(:cm2) { FactoryBot.create :committee_member, committee_role: cm_role }

    before do
      submission.committee_members << [cm1, cm2]
      submission.update status: 'waiting for committee review'
      submission.reload
    end

    it "is sent to the proper recipient" do
      expect(email.to).to eq(submission.committee_email_list)
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "sets an appropriate subject" do
      expect(email.subject).to eq("Final Submission Returned to Student for Resubmission")
    end

    it "has desired content" do
      expect(email.body).to match(/#{submission.author.full_name}'s eTD submission titled "#{submission.title}"/)
    end
  end

  describe '#committee_member_review_reminder' do
    let(:email) { described_class.committee_member_review_reminder(submission, committee_member) }

    it "is sent to the proper recipient" do
      expect(email.to).to eq([committee_member.email])
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "sets an appropriate subject", honors: true, milsch: true do
      expect(email.subject).to eq("Honors #{submission.degree_type} Needs Approval") if current_partner.honors?
      expect(email.subject).to eq("#{submission.degree_type} Needs Approval") if current_partner.graduate?
      expect(email.subject).to eq("Millennium Scholars #{submission.degree_type} Review") if current_partner.milsch?
    end

    it "has desired content" do
      expect(email.body).to match(/\/approver/)
      expect(email.body).to match(/Reminder:/)
    end

    it "updates submission's approval_started_at if blank" do
      committee_member.update approval_started_at: nil
      committee_member.reload
      email.deliver
      expect(committee_member.approval_started_at).to be_truthy
      timestamp = (DateTime.now - 1.day)
      committee_member.update approval_started_at: timestamp
      committee_member.reload
      email.deliver
      expect(committee_member.approval_started_at.to_date).to eq timestamp.to_date
    end
  end

  describe '#advisor_rejected' do
    let(:email) { described_class.advisor_rejected(submission) }

    it "is sent to the proper recipient" do
      expect(email.to).to eq([submission.author.psu_email_address])
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "sets an appropriate subject" do
      expect(email.subject).to eq("Advisor Rejected Submission")
    end

    it "has desired content" do
      expect(email.body).to match(/rejected by your advisor/)
    end
  end

  describe '#advisor_funding_discrepancy' do
    let(:email) { described_class.advisor_funding_discrepancy(submission) }

    before do
      create_committee(submission)
    end

    it "is sent to the proper recipient" do
      expect(email.to).to eq([submission.author.psu_email_address])
    end

    it "cc's advisor" do
      expect(email.cc).to eq([submission.advisor.email])
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "sets an appropriate subject" do
      expect(email.subject).to eq("Advisor Funding Discrepancy")
    end

    context 'when advisor chose true for federal funding' do
      it "has desired content" do
        submission.advisor.update federal_funding_used: true
        expect(email.body).to match(/ that federal funds were used/)
      end
    end

    context 'when advisor chose false for federal funding' do
      it "has desired content" do
        submission.advisor.update federal_funding_used: false
        expect(email.body).to match(/ that federal funds were not used/)
      end
    end
  end

  describe '#committee_member_review_request' do
    let(:email) { described_class.committee_member_review_request(submission, committee_member) }

    it "is sent to the proper recipient" do
      expect(email.to).to eq([committee_member.email])
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "sets an appropriate subject", honors: true, milsch: true do
      expect(email.subject).to eq("#{submission.degree_type} Needs Approval") if current_partner.graduate?
      expect(email.subject).to eq("Honors Thesis Needs Approval") if current_partner.honors?
      expect(email.subject).to eq("Millennium Scholars Thesis Review") if current_partner.milsch?
    end

    it "has desired content" do
      expect(email.body).to match(/\/approver/)
      expect(email.body).to match(/Hello/)
    end

    it "updates submission's approval_started_at if blank" do
      committee_member.update approval_started_at: nil
      committee_member.reload
      email.deliver
      expect(committee_member.approval_started_at).to be_truthy
      timestamp = (DateTime.now - 1.day)
      committee_member.update approval_started_at: timestamp
      committee_member.reload
      email.deliver
      expect(committee_member.approval_started_at.to_date).to eq timestamp.to_date
    end
  end

  describe '#special_committee_review_reminder' do
    context 'when committee member token exists' do
      let!(:commmittee_member_token) { FactoryBot.create :committee_member_token, committee_member: committee_member }
      let(:email) { described_class.special_committee_review_request(submission, committee_member) }

      it "is sent to the proper recipient" do
        expect(email.to).to eq([committee_member.email])
      end

      it "is sent from the partner support email address" do
        expect(email.from).to eq([partner_email])
      end

      it "sets an appropriate subject", honors: true, milsch: true do
        expect(email.subject).to eq("Honors #{submission.degree_type} Needs Approval") if current_partner.honors?
        expect(email.subject).to eq("#{submission.degree_type} Needs Approval") if current_partner.graduate?
        expect(email.subject).to eq("Millennium Scholars #{submission.degree_type} Review") if current_partner.milsch?
      end

      it "has desired content" do
        skip 'Graduate Only' unless current_partner.graduate?

        expect(email.body).to match(/\/special_committee\/#{commmittee_member_token.authentication_token.to_s}/)
        expect(email.body).to match(/The Graduate School of The Pennsylvania State University/)
      end

      it "updates submission's approval_started_at if blank" do
        committee_member.update approval_started_at: nil
        committee_member.reload
        email.deliver
        expect(committee_member.approval_started_at).to be_truthy
        timestamp = (DateTime.now - 1.day)
        committee_member.update approval_started_at: timestamp
        committee_member.reload
        email.deliver
        expect(committee_member.approval_started_at.to_date).to eq timestamp.to_date
      end
    end

    context "when committee member token doesn't exist" do
      let(:email) { described_class.special_committee_review_request(submission, committee_member) }

      it "has an 'X' in the url in place of a token" do
        skip 'Graduate Only' unless current_partner.graduate?

        expect(email.body).to match(/\/special_committee\/X/)
        expect(email.body).to match(/The Graduate School of The Pennsylvania State University/)
      end
    end
  end
end
