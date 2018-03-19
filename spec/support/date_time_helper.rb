def formatted_time(this_time)
  return 'N/A' if this_time.nil? || this_time.blank?
  formatted = this_time.strftime("%Y-%m-%d %H:%M:%S") || ''
  formatted
end

def formatted_date(this_date)
  time_date = Time.parse(this_date.to_s) || ''
  return '' if time_date == ''
  time_date.strftime('%Y-%m-%d')
end
