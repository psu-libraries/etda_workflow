RSpec.describe 'Author submission review pages', type: :integration, js: true do
  require 'integration/integration_spec_helper'

  let!(:submission) { FactoryBot.create :submission, :waiting_for_publication_release, author: current_author }
  let(:invention_disclosures) { FactoryBot.create(:invention_disclosure, submission) }
  let(:committee_member1) { FactoryBot.create :committee_member, submission: submission }
  let(:committee_member2) { FactoryBot.create :committee_member, submission: submission }
  let(:long_note) do
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Amicitiam autem adhibendam esse censent, quia sit ex eo genere, quae prosunt. An vero, inquit, quisquam potest probare, quod perceptfum, quod. Hinc ceteri particulas arripere conati suam quisque videro voluit afferre sententiam. Illum mallem levares, quo optimum atque humanissimum virum, Cn. Ne amores quidem sanctos a sapiente alienos esse arbitrantur. Duo Reges: constructio interrete. Id enim volumus, id contendimus, ut officii fructus sit ipsum officium. Hoc ille tuus non vult omnibusque ex rebus voluptatem quasi mercedem exigit.
Haec para/doca illi, nos admirabilia dicamus. Nobis aliter videtur, recte secusne, postea; Verum tamen cum de rebus grandioribus dicas, ipsae res verba rapiunt; Non quaeritur autem quid naturae tuae consentaneum sit, sed quid disciplinae. Eorum enim est haec querela, qui sibi cari sunt seseque diligunt. Paulum, cum regem Persem captum adduceret, eodem flumine invectio? Quantum Aristoxeni ingenium consumptum videmus in musicis? Fortemne possumus dicere eundem illum Torquatum? At iste non dolendi status non vocatur voluptas. Atque hoc loco similitudines eas, quibus illi uti solent, dissimillimas proferebas. Quare attende, quaeso. Et nemo nimium beatus est; Quid enim est a Chrysippo praetermissum in Stoicis? Lorem ipsum dolor sit amet, consectetur adipiscing elit. Amicitiam autem adhibendam esse censent, quia sit ex eo genere, quae prosunt. An vero, inquit, quisquam potest probare, quod perceptfum, quod. Hinc ceteri particulas arripere conati suam quisque videro voluit afferre sententiam. Illum mallem levares, quo optimum atque humanissimum virum, Cn. Ne amores quidem sanctos a sapiente alienos esse arbitrantur. Duo Reges: constructio interrete. Id enim volumus, id contendimus, ut officii fructus sit ipsum officium. Hoc ille tuus non vult omnibusque ex rebus voluptatem quasi mercedem exigit. Et nemo nimium beatus est; Quid enim est a Chrysippo praetermissum in Stoicis?'
  end

  before do
    FactoryBot.create :format_review_file, submission: submission
    FactoryBot.create :final_submission_file, submission: submission
    submission.committee_members << committee_member1
    submission.committee_members << committee_member2
    submission.access_level = 'restricted'
    submission.invention_disclosure.id_number = '1234'
    submission.restricted_notes = long_note + long_note + long_note + long_note + long_note + long_note + long_note
    submission.save
    webaccess_authorize_author
    visit author_submissions_path
  end
  context 'author can review program information' do
    it 'displays program information for the submission' do
      visit "/author/submissions/#{submission.id}/program_information"
      expect(page).to have_content(submission.title)
      page.find(:css, '#title.odd')
      expect(page).to have_content(current_partner.program_label)
      expect(page).to have_content('Semester Intending to Graduate')
      expect(page).to have_content(submission.semester)
      expect(page).to have_content('Graduation Year')
      expect(page).to have_content(submission.year)
      expect(page).to have_link('Return to dashboard')
    end
  end
  context 'author can review submission committee information' do
    it 'displays program information for the submission' do
      visit "/author/submissions/#{submission.id}/committee_members"
      expect(page).to have_content('Committee Members')
      expect(page).to have_content('Name')
      expect(page).to have_content('Role')
      expect(page).to have_content('Email')
      expect(page.find(:css, 'table.table tbody').first('tr.odd')).to be_truthy
      expect(page).to have_content(submission.committee_members[0].name)
      expect(page).to have_content(submission.committee_members[1].name)
      expect(page).to have_content(submission.committee_members[0].role)
      expect(page).to have_link('Return to dashboard')
    end
  end
  context 'author can review format review information' do
    it 'displays format review information for the submission' do
      visit "/author/submissions/#{submission.id}/format_review"
      expect(page).to have_content('Format Review Files')
      expect(page).to have_content(submission.title)
      expect(page).to have_content(submission.format_review_files.first.asset.identifier)
      expect(page).to have_link('Return to dashboard')
    end
  end
  context 'author can review final submission information' do
    it 'displays final submission information' do
      visit "/author/submissions/#{submission.id}/final_submission"
      expect(page).to have_content('Final Submission Files')
      expect(page).to have_content(submission.title)
      expect(page).to have_content('Date defended') if current_partner.graduate?
      expect(page).to have_content('Keywords')
      expect(page).to have_content(submission.keywords.first.word)
      expect(page).to have_content('Access level')
      expect(page).to have_content(submission.current_access_level.label)
      expect(page).to have_content(submission.final_submission_files.first.asset.identifier)
      expect(page).to have_content(submission.invention_disclosures.first.id_number)
      expect(page).to have_content(submission.restricted_notes)
      expect(page).to have_content(long_note + long_note + long_note + long_note + long_note + long_note + long_note)
      expect(page).to have_link('Return to dashboard')
    end
  end
end
