module ApplicationHelper
  def simple_time(time_value)
    puts "SIMPLE TIME <#{time_value}> <#{time_value.beginning_of_day}> <#{Time.zone.now.beginning_of_day}> x#{(Time.zone.now.beginning_of_day - 1.day)}x"
    if(time_value.beginning_of_day == Time.zone.now.beginning_of_day)
      puts "1"
      "Today at#{time_value.in_time_zone('Eastern Time (US & Canada)').strftime('%l%p')}"
    elsif(time_value.beginning_of_day == (Time.zone.now.beginning_of_day - 1.day))
      puts "2"
      "Yesterday at#{time_value.in_time_zone('Eastern Time (US & Canada)').strftime('%l%p')}"
    else
      puts "3"
      time_value.in_time_zone('Eastern Time (US & Canada)').strftime('%A at%l%p')
    end
  end
end
