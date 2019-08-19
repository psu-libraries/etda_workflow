namespace :tokens do
  desc "Removes expired committee member tokens from db."
  task remove_expired: :environment do
    expired_tokens = CommitteeMemberToken.where("token_created_on <= ? ", (Date.today - 180.days))
    expired_tokens_count = expired_tokens.count
    CommitteeMemberToken.destroy(expired_tokens.map(&:id))
    Rails.logger.info("Removed #{expired_tokens_count} expired committee member #{'token'.pluralize(expired_tokens_count)}.")
  end
end
