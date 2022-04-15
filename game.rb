require 'yaml'

class Game
    def initialize
        ask_to_load 
        make_file
        guessing_filler
        choose_secret_word
        clone_secret_word
        initialize_wrong_letter_array
        initialize_unknown_word
        loop_until_result
    end

    def ask_to_load
        if Dir.exists?('saved_games') && Dir.children('saved_games').length != 0
            print "Do you want to load a previous game session? (Y/N) "
            while answer = gets.chomp
                unless answer.upcase == 'Y' || answer.upcase == 'N'
                    puts "The answer needs to be Y or N (Yes or No). Try again."
                else
                    break
                end  
            end
            print "Saved sessions: "
            show_word(Dir.children('saved_games'))
            print "\n\n"
            puts "Which one would you like to load into?"
            while file_name = gets.chomp
                unless Dir.children('saved_games').any?(file_name)
                  puts "File not found. Try again."
                  print "\n"
                else
                  break
                end
            end
            load(file_name)
        end
    end

    def make_file
        puts "Getting 7.5 out of 10 kilowords..."
        @file = File.read('google-10000-english-no-swears.txt').split.select { |word| word.length.between?(5,12) } # selects words of length between 5-12
    end

    def guessing_filler
        puts "Picking a word..."    
        puts "Hmm"

        20.times do
        array = Array.new(Random.rand(5..12), '.')
        array.each { |dot| print dot }
        print "\n"
        print_whitespace(Random.rand(12))
        sleep 0.4
        end
        print "\n"
    end

    def choose_secret_word
        @secret_word = @file.sample 
    end

    def initialize_wrong_letter_array
        @wrong_letter_array = []
    end

    def initialize_unknown_word
        @unknown_word = Array.new(@disposable_secret_word.length, '?')
    end

    def show_word(word)
        word.length.times { |index| print "#{word[index]}\s" }
        print "\n"
    end

    def loop_until_result
        show_word(@unknown_word)
        until game_won? || game_lost?
            print 'Enter letter: (save game by adding "save") '
            while chosen_letter = gets.chomp.downcase
                save if chosen_letter.downcase.include?('save')
                unless chosen_letter.match?(/[a-z]/) && chosen_letter.length == 1
                    unless chosen_letter.length == 1
                        puts "It needs to be one character. Try again."
                    else
                        puts "The letter needs to be an alphabetical character. Try again."
                    end
                else
                    break
                end 
            end
            if @disposable_secret_word.include?(chosen_letter)
              @disposable_secret_word.length.times do |index|
                if @disposable_secret_word[index] == chosen_letter && @disposable_secret_word[index] != '0'
                  @unknown_word[index] = chosen_letter
                  @disposable_secret_word[index] = '1'
                end
              end
              @disposable_secret_word.gsub!('1', '0')
          
            elsif @disposable_secret_word.split('').none?('1')
              @wrong_letter_array.push(chosen_letter).uniq!
              puts "\n"
              if (4 - @wrong_letter_array.length).zero?
                puts "The word was..."
                print "\n"
                sleep 2
                show_word(@secret_word)
                break
              end
              print "Wrong letters: "
              show_word(@wrong_letter_array)
              print "\n"
              puts "Guesses left: #{4 - @wrong_letter_array.length}"
              puts "\n"
            end
          
            show_word(@unknown_word)
          end
    end

    def clone_secret_word
        @disposable_secret_word = @secret_word.clone
    end
    
    def game_won?
        @disposable_secret_word.split('').all?('0')
    end

    def game_lost?
        @wrong_letter_array.length == 4
    end

    def print_whitespace(number_of_whitespaces)
        number_of_whitespaces.times { print "\s" }
    end

    def save
        Dir.mkdir('saved_games') unless Dir.exists?('saved_games')
        File.open("saved_games/saved_game_#{Dir.children('saved_games').length + 1}.yml", 'w') do |saved_game_file|
            saved_game_file.write(self.to_yaml)
            puts "Saved."
        end
    end

    def load(saved_file_name)
        puts 'Loading...'
        game = YAML.load(File.read("saved_games/#{saved_file_name}"))
        game.loop_until_result
        exit  
    end
end