class GamesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:score]
  before_action :initialize_score, only: [:new, :score]
  require "open-uri"
  require "json"
  def new
    @new = []
    8.times{@new <<  ("a".."z").to_a.sample}
    2.times{@new <<  ["a", "e", "i", "o", "u"].sample}
  end

  def score
    logger.debug "Session CSRF Token: #{session[:_csrf_token]}"
    logger.debug "Form CSRF Token: #{params[:authenticity_token]}"
    guess = params[:guess]
    letters = params[:letters].chars # Convert back to an array of letters

    # Check word validity via the API
    result = run_api(guess)

    # Validate the word against the letters
    valid = guess.chars.all? { |letter| letters.include?(letter) }
    repeated = guess.upcase.chars.all? { |letter| guess.upcase.count(letter) <= letters.count(letter) }

    # Handle the game logic based on the results
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
    redirect_to new_path, notice: "Your score has been reset."
  end

  def initialize_score
    session[:total_score] ||= 0
  end

  def run_api(guess)
    url = "https://dictionary.lewagon.com/#{guess}"
    result_serialized = URI.open(url).read
    dictionary_hash = JSON.parse(result_serialized)
    dictionary_hash["found"]
  end
end
