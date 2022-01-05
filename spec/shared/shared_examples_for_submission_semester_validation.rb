# frozen_string_literal: true

RSpec.shared_examples "Submission semester validation" do |parameter|
  it "validates #{parameter}year only when authors are editing" do
    submission = FactoryBot.create :submission
    submission.update((parameter + 'year').to_sym => '2018')
    expect(submission).to be_valid
    submission.update((parameter + 'year').to_sym => '')
    submission.author_edit = true
    expect(submission).not_to be_valid
    submission.update((parameter + 'year').to_sym => 'abc')
    expect(submission).not_to be_valid
    submission.author_edit = false
    expect(submission).to be_valid
    submission.update((parameter + 'year').to_sym => '')
    expect(submission).to be_valid
  end

  it "validates #{parameter}semester only when authors are editing" do
    submission = FactoryBot.create :submission
    submission.update((parameter + 'semester').to_sym => 'Spring')
    expect(submission).to be_valid
    submission.update((parameter + 'semester').to_sym => '')
    submission.author_edit = true
    expect(submission).not_to be_valid
    submission.update((parameter + 'semester').to_sym => 'abc')
    expect(submission).not_to be_valid
    submission.author_edit = false
    expect(submission).to be_valid
    submission.update((parameter + 'semester').to_sym => '')
    expect(submission).to be_valid
  end
end 
