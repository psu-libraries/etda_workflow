require 'model_spec_helper'

RSpec.describe WorkflowMailer do
  let(:submission) { FactoryBot.create :submission }
  let(:committee_member) { FactoryBot.create :committee_member, submission: }
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

    context "when the current partner is 'honors'", honors: true do
      before do
        skip 'honors only' unless current_partner.honors?
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
        expect(email.body).to match(/Your format review has been approved!/i)
      end
    end

    context "when the current partner is neither 'sset' or 'honors'" do
      it "raises an exception" do
        skip 'not sset nor honors' if current_partner.sset? || current_partner.honors?

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

    context "when the current partner is 'honors'", honors: true do
      before do
        skip 'honors only' unless current_partner.honors?
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
        expect(email.body).to match(/Your format review has been rejected./i)
      end
    end

    context "when the current partner is neither 'sset' nor 'honors'" do
      it "raises an exception" do
        skip 'not sset nor honors' if current_partner.sset? || current_partner.honors?

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
      if current_partner.graduate?
        committee_member = FactoryBot.create :committee_member,
                                             email: submission.committee_members.first.email,
                                             committee_role: (FactoryBot.create :committee_role, name: 'Advisor Chair')
        submission.committee_members << committee_member
        expect(email.to).to eq([author.psu_email_address,
                                submission.committee_members.first.email,
                                submission.committee_members.second.email])
      end
      expect(email.to).to eq([author.psu_email_address]) unless current_partner.graduate?
    end

    it "tells the author that the final submission has been approved" do
      expect(email.body).to match(/This was the result of your committee's review:/) if current_partner.graduate?
      expect(email.body).to match(/You will need to make the necessary revisions/) unless current_partner.graduate?
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

  describe '#committee_rejected_committee', honors: true, sset: true, milsch: true do
    let(:email) { described_class.committee_rejected_committee(submission) }

    before do
      create_committee submission
    end

    it "sets an appropriate subject" do
      expect(email.subject).to eq "Committee Rejected Final Submission"
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "is sent to the student's PSU email address" do
      expect(email.to).to eq(submission.committee_members.pluck(:email)[2..]) if current_partner.graduate?
      expect(email.to).to eq(submission.committee_members.pluck(:email)) unless current_partner.graduate?
    end

    it "tells the author that the final submission has been approved" do
      expect(email.body).to match(/has been rejected by its committee/i)
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
      expect(email.body.raw_source).to eq("Verify Files\r\n\r\nMisplaced files found.\r\n")
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

    it "sets an appropriate subject", honors: true, milsch: true, sset: true do
      expect(email.subject).to eq("#{current_partner.name} #{submission.degree_type} Review Reminder")
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

  describe '#nonvoting_approval_reminder' do
    let(:email) { described_class.nonvoting_approval_reminder(submission, committee_member) }

    it "is sent to the proper recipient" do
      expect(email.to).to eq([committee_member.email])
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "sets an appropriate subject" do
      expect(email.subject).to eq("#{current_partner.name} #{submission.degree_type} Final Review Reminder")
    end

    it "has desired content" do
      expect(email.body).to match(/\/approver/)
      expect(email.body).to match(/final opportunity to vote/)
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

    it "sets an appropriate subject", honors: true, milsch: true, sset: true do
      expect(email.subject).to eq("#{current_partner.name} #{submission.degree_type} Review Request")
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

    it "has the seven day warning note for core committee members" do
      expect(email.body).to match(/seven days/)
    end

    context "non-core committee members" do
      let(:cm_role) { FactoryBot.create :committee_role, is_program_head: true }
      let(:committee_member) { FactoryBot.create :committee_member, committee_role: cm_role, submission: }

      it "does not have the seven day note for other committee members" do
        expect(email.body).not_to match(/seven days/)
      end
    end
  end

  describe '#special_committee_review_reminder' do
    context 'when committee member token exists' do
      let!(:commmittee_member_token) { FactoryBot.create :committee_member_token, committee_member: }
      let(:email) { described_class.special_committee_review_request(submission, committee_member) }

      it "is sent to the proper recipient" do
        expect(email.to).to eq([committee_member.email])
      end

      it "is sent from the partner support email address" do
        expect(email.from).to eq([partner_email])
      end

      it "sets an appropriate subject", honors: true, milsch: true, sset: true do
        expect(email.subject).to eq("#{current_partner.name} #{submission.degree_type} Review Request")
      end

      it "has desired content" do
        skip 'Graduate Only' unless current_partner.graduate?

        expect(email.body).to match(/\/special_committee\/#{commmittee_member_token.authentication_token}/)
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

      context "initial request" do
        it "has the seven day warning note" do
          expect(email.body).to match(/seven days/)
        end
      end

      context "reminder email" do
        it "does not have the seven day note for other committee members" do
          timestamp = (DateTime.now - 1.day)
          committee_member.update approval_started_at: timestamp
          committee_member.reload
          email.deliver
          expect(email.body).not_to match(/seven days/)
        end
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

  describe '#seventh_day_to_chairs' do
    let(:email) { described_class.seventh_day_to_chairs(submission) }
    let(:cm_role) { FactoryBot.create :committee_role, is_program_head: true, degree_type: DegreeType.default }
    let(:cm1) { FactoryBot.create :committee_member, committee_role: cm_role, is_voting: false }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: DegreeType.default }

    before do
      create_committee submission
      submission.committee_members << cm1
      submission.update status: 'waiting for committee review'
      submission.committee_members.first.update status: 'approved'
      submission.committee_members.second.update status: 'approved'
      submission.reload
    end

    it "is sent to the proper recipients" do
      expect(email.to).to eq([submission.program_head.email, submission.chairs.pluck(:email)].flatten)
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "sets an appropriate subject" do
      expect(email.subject).to eq("#{submission.author.first_name} #{submission.author.last_name} Committee 7-day Deadline Reached")
    end

    it "has desired content" do
      expect(email.body).to match(/has not completed its review after 7 days/)
      expect(email.body).not_to match(/Professor Buck Murphy (#{submission.committee_members.first.email})/)
      expect(email.body).not_to match(/Professor Buck Murphy (#{submission.committee_members.second.email})/)
      expect(email.body).not_to match(/Professor Buck Murphy (#{submission.committee_members.last.email})/)
      expect(email.body).to match(/(#{submission.committee_members.third.email})/)
      expect(email.body).to match(/(#{submission.committee_members.fourth.email})/)
      expect(email.body).to match(/(#{submission.committee_members.fifth.email})/)
      expect(email.body).to match(/(#{submission.committee_members[5].email})/)
    end
  end

  describe '#seventh_day_to_author' do
    let(:email) { described_class.seventh_day_to_author(submission) }
    let(:cm_role) { FactoryBot.create :committee_role, is_program_head: true, degree_type: DegreeType.default }
    let(:cm1) { FactoryBot.create :committee_member, committee_role: cm_role, is_voting: false, name: 'Test Test' }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: DegreeType.default }

    before do
      create_committee submission
      submission.committee_members << cm1
      submission.update status: 'waiting for committee review'
      submission.committee_members.first.update status: 'approved'
      submission.committee_members.second.update status: 'approved'
      submission.reload
    end

    it "is sent to the proper recipients" do
      expect(email.to).to eq([submission.author.psu_email_address])
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "sets an appropriate subject" do
      expect(email.subject).to eq("ETD Committee Still Processing")
    end

    it "has desired content" do
      expect(email.body).to match(/necessary votes for completion.  This matter should be fixed in the next 5 business days/)
      expect(email.body).to match(/#{submission.chairs.first.name}/)
      expect(email.body).to match(/#{submission.program_head.name}/)
    end
  end
end
