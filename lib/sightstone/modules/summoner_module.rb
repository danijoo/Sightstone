require 'sightstone/modules/sightstone_base_module'
require 'sightstone/summoner'
require 'sightstone/masterybook'
require 'sightstone/runebook'
require 'open-uri'

module Sightstone
# Module to provide calls to the summoner api
class SummonerModule < SightstoneBaseModule
  
  def initialize(sightstone)
    @sightstone = sightstone
  end

  # returns a summoner object
  # @param name_or_id [Integer, String] name or id of the summoner
  # @param optional [Hash] optional arguments: :region => replaces default region
  # @ return [Summoner] summoner
  def summoner(name_or_id, optional={})
    region = optional[:region] || @sightstone.region
    uri = if name_or_id.is_a? Integer
      "https://prod.api.pvp.net/api/lol/#{region}/v1.2/summoner/#{name_or_id}"
    else
      "https://prod.api.pvp.net/api/lol/#{region}/v1.2/summoner/by-name/#{URI::encode(name_or_id)}"
    end
    
    response = _get_api_response(uri)
    _parse_response(response) { |resp|
      data = JSON.parse(resp)
      s = Summoner.new(data)
      if block_given?
        yield s
      else
        return s
      end
    }
  end

  # returns the names for the ids
  # @param ids [Array<Numeric>] ids
  # @param optional [Hash<Symbol, String>] optional arguments: :region => replaces default region
  # @return [Hash<Numeric, String>] a hash matching each id to the summoners name
  def names(ids, optional={})
    region = optional[:region] || @sightstone.region
    ids = ids.join(',')
    uri = "http://prod.api.pvp.net/api/lol/#{region}/v1.2/summoner/#{ids}/name"
    response = _get_api_response(uri)
    _parse_response(response) { |resp|
      data = JSON.parse(resp)
      names_array = data['summoners']
      names_hash = Hash.new
      names_array.each do |summoner|
        names_hash[summoner['id']] = summoner['name']
      end
      if block_given?
        yield names_hash
      else
        return names_hash
      end
    }
  end

  # returns the runebook of a summoner
  # @param summoner [Summoner, id] summoner object or id of a summoner
  # @param optional [Hash<Symbol, String>] optional arguments: :region => replaces default region
  # @return [Runebook] runebook of the summoner
  def runes(summoner, optional={})
    region = optional[:region] || @sightstone.region
    id = if summoner.is_a? Summoner
      summoner.id
    else
      summoner
    end
    uri = "http://prod.api.pvp.net/api/lol/#{region}/v1.2/summoner/#{id}/runes"
    response = _get_api_response(uri)
    _parse_response(response) { |resp|
      data = JSON.parse(resp)
      book = RuneBook.new(data)
      if block_given?
        yield book
      else
        return book
      end
    }
  end

  # returns the masterybook of a summoner
  # @param summoner [Summoner, id] summoner object or id of a summoner
  # @param optional [Hash<Symbol, String>] optional arguments: :region => replaces default region
  # @return [Masterybook] masterybook of the summoner
  def masteries(summoner, optional={})
    region = optional[:region] || @sightstone.region
     id = if summoner.is_a? Summoner
      summoner.id
    else
      summoner
    end
    uri = "http://prod.api.pvp.net/api/lol/#{region}/v1.2/summoner/#{id}/masteries"
    response = _get_api_response(uri)
    _parse_response(response) { |resp|
      data = JSON.parse(resp)
      book =  MasteryBook.new(data)
      if block_given?
        yield book
      else
        return book
      end
    }
  end
end
end
