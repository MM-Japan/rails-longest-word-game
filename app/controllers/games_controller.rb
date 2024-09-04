class GamesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:score]
  before_action :initialize_score, only: [:new, :score]
  require "open-uri"
  require "json"

  def new
    initialize_letters
  end

  def score
    initialize_letters unless params[:letters] # Ensure @new is set if not passed via params
    guess = params[:guess]
    letters = params[:letters].chars

    result = run_api(guess)
    valid = guess.chars.all? { |letter| letters.include?(letter) }
    repeated = guess.upcase.chars.all? { |letter| guess.upcase.count(letter) <= letters.count(letter) }

    if result && valid && !repeated
      @word_length = guess.length
      @message = "Well done!"
      session[:total_score] += @word_length
    elsif result
      @word_length = 0
      @message = "Sorry, your word doesn't match."
    else
      @word_length = 0
      @message = "That was not an English word."
    end
  end

  def reset_score
    session[:total_score] = 0
    flash.now[:notice] = "Your score has been reset."
    initialize_letters
    render :new
  end

  private

  def initialize_score
    session[:total_score] ||= 0
  end

  def initialize_letters
    @new = []
    8.times { @new << ("a".."z").to_a.sample }
    2.times { @new << ["a", "e", "i", "o", "u"].sample }
  end

  def run_api(guess)
    url = "https://dictionary.lewagon.com/#{guess}"
    result_serialized = URI.open(url).read
    dictionary_hash = JSON.parse(result_serialized)
    dictionary_hash["found"]
  rescue OpenURI::HTTPError => e
    logger.error "API call failed: #{e.message}"
    false
  end
end
