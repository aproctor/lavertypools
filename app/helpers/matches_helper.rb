module MatchesHelper

  def match_name(home, away)
    return "#{away.long_name} @ #{home.long_name}"
  end

  def leader_name(match)
    if(match.spread_leader == 0)
      return match.home_team.long_name
    else
      return match.away_team.long_name
    end
  end
end
