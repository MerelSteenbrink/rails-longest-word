require 'open-uri'
require 'json'

class GameController < ApplicationController
  def play
    @grid = generate_grid(6)
  end

  def score
    @guess = params[:guess]
    start_time = params[:start_time]
    grid = params[:grid]
    end_time = Time.now
    @score = run_game(@guess, grid, start_time, end_time)
  end

def generate_grid(grid_size)
  # TODO: generate random grid of letters
  voals = %w(A E I O U Y)
  alfa = ('A'..'Z').to_a
  grid = []
  (grid_size - 1).times { grid << alfa.sample }
  grid << voals.sample
  grid
end


HASH_OPTIONS = [
  {
    time: "-",
    translation: nil,
    score: 0,
    message: "not in the grid"
  },
  {
    time: "-",
    translation: nil,
    score: 0,
    message: "not an english word"
  }
]

def play_game(attempt, trans, start_time, end_time)
  time = end_time.to_i - start_time.to_i
  { translation: trans,
    time: time,
    score: attempt.size * 100 - time,
    message: "well done"
  }
end

def dic_check(user_input)
  api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{user_input}"
  open(api_url) do |stream|
    content = JSON.parse(stream.read)
    if content['term0'].nil?
      return false
    else
      content['term0']['PrincipalTranslations']['0']['FirstTranslation']['term']
    end
  end
end




def run_game(attempt, grid, start_time, end_time)
  # TODO: runs the game and return detailed hash of result
  # First we check if you can make the word with the letters in the grid
  if !included?(attempt, grid)
    HASH_OPTIONS[0]
  else
    checkie = dic_check(attempt)
    if checkie == false # It's not in the dictionary
      HASH_OPTIONS[1]
    else # It is in the dictionary
      play_game(attempt, checkie, start_time, end_time)
    end
  end
end

def included?(user_input, grid)
   user_input.chars.all? { |letter| user_input.count(letter) <= grid.count(letter) } end
end
