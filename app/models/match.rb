class Match < ActiveRecord::Base
  belongs_to :league
  belongs_to :home_team, :class_name => "Team"
  belongs_to :away_team, :class_name => "Team"

  scope :in_range, ( lambda do |start_dt, end_dt|
    where( :start_time => (start_dt)..(end_dt) )
  end )

  def long_name()
    return "#{away_team.long_name} @ #{home_team.long_name}"
  end

  def spread_long
    favored_team = home_team.reference
    if(spread > 0)
      favored_team = away_team.reference
    end
    return "#{favored_team} favored by #{spread.abs} points"
  end

  ###
  # Returns the leading team value based on spread
  # 0 = home
  # 1 = away
  # -1 = push
  ##
  def spread_leader
    score = self.home_score - self.away_score + spread
    if(score > 0)
      return 0
    elsif(score < 0)
      return 1
    else
      return -1
    end
  end
end
