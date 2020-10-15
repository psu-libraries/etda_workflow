# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe EmailContactForm, honors: true, type: :model do
  let(:mail_form) do
    EmailContactForm.new(
      full_name: 'Test',
      email: 'test123@psu.edu',
      psu_id: '999999999',
      desc: 'Issue',
      message: 'This is an issue',
      issue_type: :failures
    )
  end

  describe '#headers' do
    context 'when failure issue' do
      it 'has headers with "to" address to IT support and "from" address is sender\'s email' do
        expect(mail_form.headers).to eq(from: 'test123@psu.edu',
                                        to: 'uletdasupport@psu.edu',
                                        subject: "#{current_partner.slug} Contact Form")
      end
    end

    context 'when general/technical issue', honors: true, milsch: true do
      it 'has headers with "to" address to partner and "from" address is no-reply@psu.edu' do
        mail_form.issue_type = :general
        to_address = 'gradthesis@psu.edu' if current_partner.graduate?
        to_address = 'honorsthesis@psu.edu' if current_partner.honors?
        to_address = 'millennium@psu.edu' if current_partner.milsch?
        expect(mail_form.headers).to eq(from: 'no-reply@psu.edu',
                                        to: to_address,
                                        subject: "#{current_partner.slug} Contact Form")
      end
    end
  end

  describe '#issue_type_valid?' do
    context 'when issue_type is :failures or :formatting' do
      it 'returns true' do
        mail_form.issue_type = :general
        expect(mail_form.issue_type_valid?).to eq true
        mail_form.issue_type = :failures
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
