require 'sightstone/summoner'
require 'sightstone/league'

class LeagueModule
  def initialize(sightstone)
    @sightstone = sightstone
  end
  
  def league(summoner)
    id = if summoner.is_a? Summoner
      summoner.id
    else
      summoner
    end
    
    uri = "http://prod.api.pvp.net/api/#{@sightstone.region}/v2.1/league/by-summoner/#{id}"
    response = _get_api_response(uri)
    _parse_response(response) { |resp|
      data = JSON.parse(resp)
      leagueKeys = data.keys
      leagues = []
      leagueKeys.each do |key|
        leagues << League.new(data[key])
      end
      return leagues
    }
  end
  
   private

  def _get_api_response(uri)
    params = {'api_key' => @sightstone.api_key}
    RestClient.get(uri, headers={:params => params}) {|response, request, result| response }
  rescue SocketError => e
    nil

    end

  def _parse_response(response, &block)
    response_code = if response.nil?
    500
    else
    response.code
    end
    if response_code == 200
    block.call(response.body)
    elsif response_code == 404
      raise Sightstone::SummonerNotFoundException
    elsif response_code == 500
      raise Sightstone::SightstoneConnectionException
    end
  end
end