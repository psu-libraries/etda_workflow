# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe EmailContactForm, type: :model do
  let(:mail_form) do
    EmailContactForm.new(
      full_name: 'Test',
      email: 'test123',
      psu_id: '999999999',
      desc: 'Issue',
      message: 'This is an issue',
      issue_type: :technical
    )
  end

  describe '#headers' do
    context 'when technical issue' do
      it 'has headers with "to" address to IT support' do
        expect(mail_form.headers).to eq(from: 'no-reply@psu.edu',
                                        to: 'uletdasupport@psu.edu',
                                        subject: "#{current_partner.slug} Contact Form")
      end
    end

    context 'when nontechnical issue' do
      it 'has headers with "to" address to partner' do
        mail_form.issue_type = :formatting
        expect(mail_form.headers).to eq(from: 'no-reply@psu.edu',
                                        to: 'gradthesis@psu.edu',
                                        subject: "#{current_partner.slug} Contact Form")
      end
    end
  end

  describe '#issue_type_valid?' do
    context 'when issue_type is :technical or :formatting' do
      it 'returns true' do
        mail_form.issue_type = :formatting
        expect(mail_form.issue_type_valid?).to eq true
        mail_form.issue_type = :technical
        expect(mail_form.issue_type_valid?).to eq true
      end
    end

    context 'when issue_type is  not valid' do
      it 'returns invalid message' do
        mail_form.issue_type = :bogus
        expect(mail_form.issue_type_valid?).to eq ["Invalid Issue Type"]
      end
    end
  end
end