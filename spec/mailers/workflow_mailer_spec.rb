require 'model_spec_helper'

RSpec.describe WorkflowMailer do
  let(:submission) { FactoryBot.create :submission }
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
    let(:email) { described_class.final_submission_approved(submission, 'http://test_this_url:999') }

    it 'contains publication information for graduate dissertations' do
      publication_message = t("#{current_partner.id}.partner.email.final_submission_approved.dissertation_publish_msg")
      if current_partner.graduate?
        expect(email.body).to include(publication_message)
      else
        expect(email.body).not_to include(publication_message)
      end
    end

    it "sets an appropriate subject" do
      expect(email.subject).to match(/has been approved/i)
    end

    it "is sent from the partner support email address" do
      expect(email.from).to eq([partner_email])
    end

    it "is sent to the student's PSU email address" do
      expect(email.to).to eq([author.psu_email_address])
    end

    it "is carbon copied to the committee members for honors and graduate school " do
      expect(email.cc).to eq(submission.committee_email_list)
    end

    it "tells the author that the final submission has been approved" do
      expect(email.body).to match(/has been reviewed and approved/i) if current_partner.graduate?
      expect(email.body).to match(/has been approved/i) if current_partner.honors?
    end

    it 'contains the url to the partner site' do
      expect(email.body).to match(/http:\/\/test_this_url:999/i)
    end
  end

  describe '#pay_thesis_fee' do
    before { allow(Partner).to receive(:current).and_return(partner) }

    let(:email) { described_class.pay_thesis_fee(submission) }

    context "when the current partner is 'graduate'" do
      let(:partner) { Partner.new('graduate') }

      xit "raises an exception" do
        expect { email.deliver_now }.to raise_error ActionView::Template::Error
      end
    end

    context "when the current partner is 'honors'" do
      let(:partner) { Partner.new('honors') }

      it "sets an appropriate subject" do
        expect(email.subject).to match(/thesis processing fee/i)
      end

      it "is sent from the partner support email address" do
        expect(email.from).to eq([partner.email_address])
      end

      it "is sent to the student's PSU email address" do
        expect(email.to).to eq([author.psu_email_address])
      end

      it "tells the author to pay thesis processing fee" do
        expect(email.body).to match(/pay the thesis processing fee/i)
      end
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
end
