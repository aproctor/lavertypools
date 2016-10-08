class Pool < ActiveRecord::Base
  belongs_to :league
  has_many :players_pools
  has_many :players, through: :players_pools

  def matches
    return Match.in_range(self.start_time, self.end_time).order(:start_time)
  end

  def locked?
    matches.each do |m|
      if(m.nil?)
        puts "Strange, this match is nil****"
      end

      # if(m.start_time < Time.zone.now)
      #   return true
      # end
    end
    return false
  end
end
