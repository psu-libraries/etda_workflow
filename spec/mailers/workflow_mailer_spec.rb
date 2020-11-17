require 'model_spec_helper'

RSpec.describe WorkflowMailer do
  let(:submission) { FactoryBot.create :submission }
  let(:committee_member) { FactoryBot.create :committee_member, submission: submission }
  let(:commmittee_member_token) { FactoryBot.create :committee_member_token, committee_member: committee_member }
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

    it "tells the author that the final submission has been approved", honors: true, milsch: true do
      expect(email.body).to match(/It will now be automatically sent to your committee/i) if current_partner.graduate?
      expect(email.body).to match(/has been approved/i) if current_partner.honors?
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
      expect(email.body).to match(/Congratulations!/i)
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
    let(:csv) { CSV.generate { |csv| csv << ['HEADERS']} }
    let(:email) { described_class.open_access_report(date_range, csv) }

    it "sets an appropriate subject" do
      expect(email.subject).to eq "eTDs Released as Open Access #{date_range}"
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "has csv attachment" do
      expect(email.attachments.first.filename).to eq("open_access_report.csv")
    end

    it "contains information about publications released as open access this semester" do
      expect(email.body).to match(/were released as Open Access between #{date_range}/i)
      expect(email.body).to match(/#{current_partner.name}/i)
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
