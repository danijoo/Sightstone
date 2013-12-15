require 'sightstone/modules/sightstone_base_module'
require 'sightstone/summoner'
require 'sightstone/team'

class TeamModule < SightstoneBaseModule
  def initialize(sightstone)
    @sightstone = sightstone
  end

  def teams(summoner, optional={})
    region = optional[:region] || @sightstone.region
    id = if summoner.is_a? Summoner
      summoner.id
    else
      summoner
    end
    
    uri = "https://prod.api.pvp.net/api/#{region}/v2.1/team/by-summoner/#{id}"

    response = _get_api_response(uri)
    _parse_response(response) { |resp|
      data = JSON.parse(resp)
      teams = []
      data.each do |team|
        teams << Team.new(team)
      end
      return teams
    }
  end

end
