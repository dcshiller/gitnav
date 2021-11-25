# Taken from Rails ActionView date helper and simplified.

def distance_of_time_in_words(from_time, to_time = 0)
  from_time = from_time.to_time if from_time.respond_to?(:to_time)
  to_time = to_time.to_time if to_time.respond_to?(:to_time)
  from_time, to_time = to_time, from_time if from_time > to_time
  distance_in_minutes = ((to_time - from_time) / 60.0).round
  case distance_in_minutes
  when 0..1
    return distance_in_minutes == 0 ?
           "less than #{count} minutes":
           "#{count} minute#{count === 1 ? '' : 's'}"

  when 2...45           then  "#{count} minutes"
  when 45...90          then  "about 1 hour"
  # 90 mins up to 24 hours
  when 90...1440
    distance_in_hours = (distance_in_minutes.to_f / 60.0).round
    "about #{distance_in_hours} hour#{distance_in_hours == 1 ? '' : 's'}"
  # 24 hours up to 42 hours
  when 1440...2520      then "1 day"
  # 42 hours up to 30 days
  when 2520...43200     then "#{(distance_in_minutes.to_f / 1440.0).round} days"
  # 30 days up to 60 days
    #
  when 43200...86400
    distance_in_months = (distance_in_minutes.to_f / 43200.0).round
    "about #{distance_in_months} month#{distance_in_months == 1 ? '' : 's'}"
  # 60 days up to 365 days
  when 86400...525600   then  "#{(distance_in_minutes.to_f / 43200.0).round} months"
  else
    minutes_with_offset = distance_in_minutes
    remainder                   = (minutes_with_offset % 525600)
    distance_in_years           = (minutes_with_offset.div 525600)
    if remainder < 131400
       "about #{distance_in_years} year#{distance_in_years == 1 ? '' : 's'}"
    elsif remainder < 394200
      "over #{distance_in_years} year#{distance_in_years == 1 ? '' : 's'}"
    else
      "almost #{distance_in_years + 1} years"
    end
  end
end

def time_ago_in_words(from_time)
  distance_of_time_in_words(from_time, Time.now)
end


