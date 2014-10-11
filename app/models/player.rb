class Player < ActiveRecord::Base
  has_many :players_pools
  has_many :pools, through: :players_pools

  def score_for_pool(pool)
    score = 0
    picks = []
    pool.matches.each do |m|
      pick = Pick.find_by(:player => self, :pool => pool, :match => m)
      if(pick.present? && pick.winner == m.spread_leader)
        score += 1
      end
    end
    return score
  end
end
