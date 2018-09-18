# frozen_string_literal: true

class InventionDisclosureNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # display error if number is entered when access level is NOT restricted
    # display error when number is not formatted correctly
    # display error when number is not entered and submission is restricted

    return true if record.access_level != 'restricted'
    # return true if invention_disclosure_empty?(record, attribute, value.id_number)
    return true if valid_id_number?(record, attribute, value.id_number)

    # Removing validation per ETDA-772; to restore, uncomment and move the following line to the end of the line above ('return true if valid_id_number?...')
    # if valid_id_number?(record, attribute, value.id_number)
    false
  end

  private

  def valid_id_number?(record, attribute, number)
    record.errors[attribute] << 'number is required for Restricted submissions.' unless number_is_valid? number
  end

  def number_is_valid?(number)
    return false if number.nil?

    num = number.strip
    return false if num.blank?

    true
  end

  def invention_disclosure_empty?(record, attribute, number)
    return true if number.nil?
    return true if number.blank?

    record.errors[attribute] << ' number should only be entered when Restricted access is selected.  Please remove the Invention Disclosure Number or select restricted access.'
    false
  end
end
