#Store methods for game Mastermind
module Mastermind
	class Game
		#create a board
		def initialize
			@board = Board.new
		end

		#prompt user for code and adds it to the board
		def get_code
			guess = nil

			until is_valid_code?(guess) do
				puts "Enter your 4 digit code"
				puts "Please choose from letters 1-6"
				guess = gets.chomp
			end

			guess = guess.split('')

			add_guess(Code.new(guess))

			guess
		end

		#check to see if a code has valid characters and length
		def is_valid_code?(guess)
			if guess.nil?
				false
			else
				if guess.length != 4
					puts "Sorry, guess needs a length of 4"
					false
				elsif !has_valid_characters(guess)
					puts "Sorry, the only valid characters are 1-6"
					false
				else
					true
				end
			end
		end

		#check to see if all characters are 1-6
		def has_valid_characters(guess)
			guess.split('').each do |x|
				unless x.to_i >= 1 && x.to_i <= 6
					return false
				end
			end

			true
		end

		#add a guess to the board
		def add_guess(guess)
			@board.attempts << guess
		end

		#add a key to the board
		def add_key(key)
			@board.keys << key
		end

		#allow player to choose whether to be code guesser or creater
		def get_player
			puts "Would you like to guess a code? y/n"
			player = gets.chomp

			if player == "y"
				:play
			elsif player == "n"
				:comp
			else
				puts "Sorry but that is not an acceptable answer."
				get_player
			end
		end

		#play the game
		def play
			solution = @board.code.code

			player = get_player

			if player == :comp
				puts "Enter your code for the computer to guess"
				solution = get_code
				c = Comp.new
			end

			guesses = 12

			guesses.times do
				if player == :play
					guess = get_code
				elsif player == :comp
					guess = c.guess
					add_guess(Code.new(guess))
					p c.possiblilites
				end

				k = Key.new(solution, guess)
				add_key(k)

				if player == :comp
					c.reduce_possibilites(guess, k)
				end

				puts @board

				break if is_won?(k) 
			end

			puts "The solution was #{solution.to_s}"
		end

		#check to see if the key indicates a victory by checking to see if all pegs
		#are X
		def is_won?(key)
			if key.key.all? {|peg| peg == 'X'}
				puts "Congratulations! You guessed the correct code"
				return true
			end

			return false
		end
	end

	#Describe the board of a Mastermind game
	class Board
		attr_accessor :code, :attempts, :keys

		#store code, attempts, and keys of the board
		def initialize
			@code = Code.new
			@attempts = []
			@keys = []
		end

		#display the board's attempts with corresponding keys
		def to_s
			s = ""

			@attempts.each_with_index do |attempt, i|
				s += "#{i + 1}. #{" " if i < 9}#{@attempts[i].to_s} #{@keys[i].to_s}\n"
			end

			s
		end
	end

	#Describe a code
	class Code
		attr_accessor :code

		#Create a code of four random colors
		def initialize(code = nil)
			code ? @code = code : @code = 4.times.map{rand(1..6)}
		end

		#Display the code
		def to_s
			@code.join('-') if @code.class == "Array"
		end
	end

	#Describe a key to crack a code
	class Key
		attr_accessor :key

		#create ordered key
		def initialize(solution, guess)
			@key = []

			self.generate(solution, guess)

			@key = @key.sort.reverse!
		end

		#create unordered key with X's representing a peg of the right type and 
		#position, O's for proper type but unproper position, and A's for an absence
		#of a correct type or position
		def generate(solution, guess)
			solution.each_with_index do |peg, i|
				if peg.to_s == guess[i]
					@key << "X"
				elsif guess.include?(peg.to_s)
					@key << "O"
				end
			end

			for i in (0...(4-@key.length))
				@key << "A"
			end
		end

		#show key as characters broken up by '-'
		def to_s
			@key.join('-')
		end
	end

	class Comp
		attr_accessor :possiblilites

		def initialize
			@possibilities = []
			possibility = []

			("1".."6").to_a.each do |first|
				possibility[0] = first
				("1".."6").to_a.each do |second|
					possibility[1] = second
					("1".."6").to_a.each do |third|
						possibility[2] = third
						("1".."6").to_a.each do |fourth|
							possibility[3] = fourth
							@possibilities << possibility.clone
						end
					end
				end
			end
		end

		def guess
			guess = @possibilities[rand(0...@possibilities.length)]
			puts "I guessed #{guess}"
			guess
		end

		def reduce_possibilites(guess, key)
			key = key.to_s
			puts key.class
			puts "#{key} == A-A-A-A results to #{key == "A-A-A-A"}"

			if key == "A-A-A-A"
				x = @possibilities.select do |code|
					guess.each do |x|
						!code.include?(x)
					end
				end
				puts @possibilities.length
				p x.length
			end
		end
	end
end

Mastermind::Game.new.play
