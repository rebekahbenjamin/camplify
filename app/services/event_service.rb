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
    booked_events = Event.where(
      year: year,
      week_number: week
    ).sort_by { |e| e.start_date }
    available_slot = []
    next_avail = nil
    booked_events.each do |event|
      start_date = DateTime.parse(event.start_date.to_s)
      end_date = DateTime.parse(event.end_date.to_s)
      if (start_date > start_date.midnight) || next_avail < start_date
        if next_avail.present? && next_avail.day < start_date.day
          slot = {
            start_date: next_avail,
            end_date: end_date.end_of_day
          }
          available_slot << slot
          next_avail = nil
        end

        if next_avail.present? && next_avail.day == start_date.day
          slot =  {
            start_date: next_avail,
            end_date: start_date
          }
        else
          slot = {
            start_date: start_date.midnight,
            end_date: start_date
          }
        end
        available_slot << slot
        next_avail = event.end_date
      end
    end
    if booked_events.last[:end_date] <= next_avail.end_of_day
      available_slot << {
        start_time: next_avail,
        end_date: booked_events.last[:end_date].end_of_day
      }
    end
    available_slot
  end
end
