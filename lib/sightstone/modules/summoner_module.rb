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
      "https://prod.api.pvp.net/api/lol/#{region}/v1.3/summoner/#{name_or_id}"
    else
      "https://prod.api.pvp.net/api/lol/#{region}/v1.3/summoner/by-name/#{URI::encode(name_or_id)}"
    end
    
    response = _get_api_response(uri)
    _parse_response(response) { |resp|
      data = JSON.parse(resp)
      s = Summoner.new(data.values[0])
      if block_given?
        yield s
      else
        return s
      end
    }
  end

  # returns an array of summoner objects
  # @param names_or_ids [Array<Integer, String>] names or ids of summoners
  # @param optional [Hash] optional arguments: :region => replaces default region
  # @return [Hash<(String or Integer), Summoner>] A Hash mapping summoner ids or names to summoner objects
  def summoners(names_or_ids, optional={})
    return {} if names_or_ids.empty?

    region = optional[:region] || @sightstone.region
    
    uri = if !names_or_ids[0].is_a? String
      "https://prod.api.pvp.net/api/lol/#{region}/v1.3/summoner/#{names_or_ids.join(',')}"
    else
      "https://prod.api.pvp.net/api/lol/#{region}/v1.3/summoner/by-name/#{URI::encode(names_or_ids.join(','))}"
    end
    
    response = _get_api_response(uri)
    _parse_response(response) { |resp|
      data = JSON.parse(resp)
      summoners = {}
      data.each do |id_or_name, raw_summoner|
        summoners[id_or_name] = Summoner.new(raw_summoner)
      end

      if block_given?
        yield summoners
      else
        return summoners
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
    uri = "https://prod.api.pvp.net/api/lol/#{region}/v1.3/summoner/#{ids}/name"
    response = _get_api_response(uri)
    _parse_response(response) { |resp|
      data = JSON.parse(resp)

      names_hash = Hash.new
      data.each do |id, name|
        names_hash[id.to_i] = name
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
  def runebook(summoner, optional={})
    region = optional[:region] || @sightstone.region
    id = if summoner.is_a? Summoner
      summoner.id
    else
      summoner
    end
    uri = "https://prod.api.pvp.net/api/lol/#{region}/v1.3/summoner/#{id}/runes"
    response = _get_api_response(uri)
    _parse_response(response) { |resp|
      data = JSON.parse(resp)
      book = RuneBook.new(data.values[0])
      if block_given?
        yield book
      else
        return book
      end
    }
  end

  # returns the runebook for multiple summoners
  # @param summoners [Array<(Summoner, Integer)>] list of summoner objects or ids of summoners
  # @param optional [Hash<Symbol, String>] optional arguments: :region => replaces default region
  # @return [Hash<Integer, Runebook>] A hash mapping runebooks to the ids of summoners
  def runebooks(summoners, optional={})
    return {} if summoners.empty?

    region = optional[:region] || @sightstone.region
    ids = summoners.collect { |summoner|
      if summoner.is_a? Summoner
        summoner.id
      else
        summoner
      end
    }
    uri = "https://prod.api.pvp.net/api/lol/#{region}/v1.3/summoner/#{ids.join(',')}/runes"
    response = _get_api_response(uri)
    _parse_response(response) { |resp|
      data = JSON.parse(resp)
      books = {}
      data.each do |key, raw_book|
        books[key] = RuneBook.new(raw_book)
      end
      if block_given?
        yield books
      else
        return books
      end
    }
  end

  # returns the masterybook of a summoner
  # @param summoner [Summoner, id] summoner object or id of a summoner
  # @param optional [Hash<Symbol, String>] optional arguments: :region => replaces default region
  # @return [Masterybook] masterybook of the summoner
  def masterybook(summoner, optional={})
    region = optional[:region] || @sightstone.region
     id = if summoner.is_a? Summoner
      summoner.id
    else
      summoner
    end
    uri = "https://prod.api.pvp.net/api/lol/#{region}/v1.3/summoner/#{id}/masteries"
    response = _get_api_response(uri)
    _parse_response(response) { |resp|
      data = JSON.parse(resp)
      book =  MasteryBook.new(data.values[0])
      if block_given?
        yield book
      else
        return book
      end
    }
  end

  # returns the masterybooks for multiple summoners
  # @param summoners [Array<(Summoner, Integer)>] list of summoner objects or ids of summoners
  # @param optional [Hash<Symbol, String>] optional arguments: :region => replaces default region
  # @return [Hash<Integer, Masterybook>] A hash mapping masterybooks to the ids of summoners
  def masterybooks(summoners, optional={})
    return {} if summoners.empty?
    region = optional[:region] || @sightstone.region
    ids = summoners.collect { |summoner|
      if summoner.is_a? Summoner
        summoner.id
      else
        summoner
      end
    }

    uri = "https://prod.api.pvp.net/api/lol/#{region}/v1.3/summoner/#{ids.join(',')}/masteries"
    response = _get_api_response(uri)
    _parse_response(response) { |resp|
      data = JSON.parse(resp)
      books = {}
      data.each do |key, raw_book|
        books[key] = MasteryBook.new(raw_book)
      end
      if block_given?
        yield books
      else
        return books
      end
    }
  end
end
end
