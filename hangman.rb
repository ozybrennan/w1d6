require 'set'

class Game

	attr_reader :secret_word, :filled_in_word, :checking_player, :guessing_player, :times

	def initialize(guessing_player, checking_player)
		@guessing_player = guessing_player
		@checking_player = checking_player
	end

	def run
		@filled_in_word = checking_player.pick_secret_word
		guessing_player.receive_secret_length(filled_in_word)
		times = 0
		until over?(times)
			times += 1
			guess = guessing_player.guess(filled_in_word)
			word = checking_player.check_guess(guess, filled_in_word)
			guessing_player.respond(guess, word)
			filled_in_word = word
		end
	end

	def over?(times)
		if !filled_in_word.include?("_")
			puts "Guessing player wins!"
			puts filled_in_word.join("")
			true
		elsif times == 10
			puts "Guessing player loses!"
			puts filled_in_word.join("")
			true
		else
			false
		end
	end
end

class HumanPlayer

	def receive_secret_length(filled_in_word)
		puts "The word is #{filled_in_word}, which is #{filled_in_word.length} letters long."
	end

	def guess(filled_in_word)
		puts "Please guess a letter."
		gets.chomp.downcase
	end

	def pick_secret_word
		puts "Please say the length of the secret word."
		length = gets.chomp.to_i
		disguised_word = ""
		length.times { disguised_word << "_" }
		disguised_word.split("")
	end

	def check_guess(guess, filled_in_word)
		puts "Is #{guess} in word? y/n"
		ans = gets.chomp.downcase
		if ans == "y"
			puts "Where is it in the word?"
			positions = gets.chomp.split("").map(&:to_i)
			positions.each do |i|
				filled_in_word[i] = guess
			end
		end
		filled_in_word
	end

	def respond
	end

end

class ComputerPlayer

	attr_reader :dictionary, :secret_word, :used_letters

	def initialize
		@dictionary = dictionary = File.readlines("dictionary.txt").map(&:chomp)
		@used_letters = []
	end

	def pick_secret_word
		@secret_word = @dictionary.sample.chomp.split("")
		disguised_word = ""
		secret_word.length.times { disguised_word << "_" }
		p disguised_word
		disguised_word.split("")
	end

	def check_guess(guess, filled_in_word)
		secret_word.each_with_index do |letter, i|
			if guess == letter
				filled_in_word[i] = letter
			end
		end
		p filled_in_word
		filled_in_word
	end

	def receive_secret_length(filled_in_word)
		length = filled_in_word.length
		@dictionary = @dictionary.to_set.select { |word| word.length == length }
	end

	def guess(filled_in_word)
		letters = {}
		@dictionary.each do |word|
			letters += word.split("")
		end
		new_guess = letters[rand(letters.length)]
		if used_letters.include?(new_guess)
			guess(filled_in_word)
		else
			used_letters << new_guess
			new_guess
		end
	end

	def respond(guess, filled_in_word)
		if filled_in_word.include?(guess)
			@dictionary = @dictionary.select {|word| is_valid?(guess, filled_in_word, word)}
		else
			@dictionary = @dictionary.reject {|word| word.split("").include?(guess) }
		end
	end


	def is_valid?(guess, filled_in_word, word)
		letters = word.split("")
		guess_indexes = []
		filled_in_word.each_with_index do |letter, index|
			guess_indexes << index if letter == guess
		end
		letters.each_with_index do |letter, i|
			if guess_indexes.include?(i)
				return false if letter != guess
			else
				return false if letter == guess
			end
		end
		true
	end
end

Game.new(ComputerPlayer.new, ComputerPlayer.new).run
