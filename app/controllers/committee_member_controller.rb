class CommitteeMemberController < ApplicationController
  layout 'home'

  def index
    @committee_member_data = CommitteeMemberDataService.new.fetch_committee_member_data

    # Extract unique college names from the data
    @colleges = @committee_member_data.map { |data| data['college'] }.uniq.sort
  end
end
