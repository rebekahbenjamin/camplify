class EventService
  def self.create(params)
    e = Event.new
    e.start_date = params[:start_date]
    e.end_date = params[:end_date]
    e.week_number = Date.parse(params[:start_date]).cweek
    e.year = Date.parse(params[:start_date]).year
    data = e.save!
  end

  def self.find(year: year, week: week)
    events = Event.where(
      year: year,
      week_number: week
    )
    available_slot = []
    next_avail = nil
    if events.any?
      available_slot = get_available_slots(events, week, year)
    else
      available_slot = fetch_full_empty_slot(week, year)
    end
    available_slot
  end

  def self.fetch_full_empty_slot(week, year)
    available_slot = []
    starting_date = Date.commercial(year, week)
    7.times do
      slot = {
        start_day: starting_date.midnight,
        end_date: starting_date.end_of_day
      }
      available_slot << slot
      starting_date = starting_date.next_day
    end
    available_slot
  end

  def self.get_available_slots(events, week, year)
    available_slot = []
    booked_events = events.sort_by { |e| e.start_date }
    starting_date = Date.commercial(year, week)
    7.times do
      booked_slots = booked_events.select do |i|
        Date.parse(i[:start_date].to_s) == starting_date
      end
      if booked_slots.any?
        next_avail = nil
        booked_slots.each do |slot|
          start_date = DateTime.parse(slot.start_date.to_s)
          end_date = DateTime.parse(slot.end_date.to_s)
          slot = nil
          if next_avail.nil?
            slot = {
              start_date: starting_date.midnight,
              end_date: start_date
            }
            next_avail = end_date
          else
            slot = {
              start_date: next_avail,
              end_date: start_date
            }
            next_avail = end_date
          end
          available_slot << slot
        end
        last_slot = booked_slots.last
        final_end_date = last_slot[:end_date]
        end_of_date = DateTime.parse(starting_date.end_of_day.to_s)
        if final_end_date != end_of_date
          final_slot = {
            start_date: last_slot[:end_date],
            end_date: end_of_date
          }
          available_slot << final_slot
        end
      else
        slot = {
          start_date: starting_date.midnight,
          end_date: starting_date.end_of_day
        }
        available_slot << slot
      end
      starting_date = starting_date.next_day
    end
    available_slot
  end
end
