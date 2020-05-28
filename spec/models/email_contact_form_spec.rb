# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe EmailContactForm, type: :model do
  describe '#headers' do
    context 'when technical issue' do
      let(:mail_form) do
        EmailContactForm.new(
                          full_name: 'Test',
                          email: 'test123',
                          psu_id: '999999999',
                          desc: 'Technical Issue',
                          message: 'This is a technical issue',
                          issue_type: :technical
      )
      end
      it 'has headers with "to" address to IT support' do
        expect(mail_form.headers).to eq({from: 'no-reply@psu.edu',
                                         to: 'uletdasupport@psu.edu',
                                         subject: "#{current_partner.slug} Contact Form"})
      end
    end

    context 'when nontechnical issue' do
      let(:mail_form) do
        EmailContactForm.new(
            full_name: 'Test',
            email: 'test123',
            psu_id: '999999999',
            desc: 'Formatting Issue',
            message: 'This is a formatting issue',
            issue_type: :formatting
        )
      end
      it 'has headers with "to" address to partner' do
        expect(mail_form.headers).to eq({from: 'no-reply@psu.edu',
                                         to: 'gradthesis@psu.edu',
                                         subject: "#{current_partner.slug} Contact Form"})
      end
    end
  end

  describe '#issue_type_valid?' do
    context 'when issue_type is :technical or :formatting' do
      let(:mail_form) do
        EmailContactForm.new(
            full_name: 'Test',
            email: 'test123',
            psu_id: '999999999',
            desc: 'Desc',
            message: 'Message',
            issue_type: :formatting
        )
      end
      it 'returns true' do
        expect(mail_form.issue_type_valid?).to eq true
        mail_form.issue_type = :technical
        expect(mail_form.issue_type_valid?).to eq true
      end
    end

    context 'when issue_type is  not valid' do
      let(:mail_form) do
        EmailContactForm.new(
            full_name: 'Test',
            email: 'test123',
            psu_id: '999999999',
            desc: 'Desc',
            message: 'Message',
            issue_type: :bogus
        )
      end
      it 'returns false' do
        expect(mail_form.issue_type_valid?).to eq false
      end
    end
  end
end
