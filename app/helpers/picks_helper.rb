module PicksHelper

  def pick_link(pick, team, is_home)
    buffer = []
    selected = false
    if(is_home == true)
      pickVal = 0
    else
      pickVal = 1
    end
    selected = (pick.winner == pickVal)

    buffer << '<div onclick="setPick(this, '
    buffer << pick.id
    buffer << ', '
    buffer << pickVal
    buffer << ')"'
    buffer << ' class="pick_link'
    if(is_home)
      buffer << ' home'
    else
      buffer << ' away'
    end
    if(selected)
      buffer << ' selected'
    end
    buffer << '" style="background-image: url(\'/images/'
    buffer << team.league.name
    buffer << '.jpg\'); background-position-x: -'
    buffer << team.logo_offset_x.to_i
    buffer << 'px; background-position-y: -'
    buffer << team.logo_offset_y.to_i
    buffer <<'px;">'
    buffer << team.reference
    buffer << '</div>'

    return raw buffer.join('')
  end
end
