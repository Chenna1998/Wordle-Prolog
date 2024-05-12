% Entry point of the game, initializes the game setup and starts the game loop
start:-
    write('----------------------'), nl,
    write('Wordle!'), nl,
    write('----------------------'), nl,
    build_kb,  % Call to build the knowledge base
    play.      % Call to start the game

% Builds the knowledge base by allowing user to input words and their categories
build_kb:-
    write('Please enter a word:'), nl,
    read(Word),  % Read a word from user
    (
        var(Word),  % Check if the input is a variable (not allowed)
        write('You cannot enter variables, try again.'), nl,
        build_kb
    ;
        Word = 'done',  % Check if the user has finished entering words
        write('Done building the words database...'), nl
    ;
        write('Please enter the category for the word:'), nl,
        read(CategoryInput),  % Read category for the word
        (
            var(CategoryInput),  % Check if the category input is a variable
            write('You cannot enter variables, try again.'), nl,
            build_kb
        ;
            assert(word(Word, CategoryInput)),  % Store the word and category in the database
            build_kb  % Recursively call build_kb to allow more words to be entered
        )
    ).

% Starts the gameplay by listing categories and managing the game logic
play:-
    write('The available categories are: '), 
    categories(CategoryList),  % Retrieve list of categories from the database
    write(CategoryList), nl,
    choose_category(ChosenCategory),  % Let the player choose a category
    choose_length(Length, ChosenCategory),  % Let the player choose a word length
    Guesses is Length + 1,  % Set the number of guesses based on word length
    write('Game started. You have '), write(Guesses), write(' guesses.'), nl, nl,
    setof(Word, pick_word(Word, Length, ChosenCategory), Words),  % Find all words that match the criteria
    random_member(ActualWord, Words),  % Randomly select one word to guess
    guess_word(ActualWord, Length, Guesses).  % Start the guessing process

% Choose a word that matches both the selected category and the length
pick_word(Word, Length, Category):-
    word(Word, Category),
    atom_length(Word, Length).

% Allows the player to choose a category from the available list
choose_category(ChosenCategory):-
    write('Choose a category: '), nl,
    read(CategoryChoice),
    (
        var(CategoryChoice),  % Check if the input is a variable
        write('Variables are not allowed, please try again.'), nl,
        choose_category(ChosenCategory)
    ;
        is_category(CategoryChoice),  % Validate if the chosen category exists
        ChosenCategory = CategoryChoice
    ;
        write('This category does not exist.'), nl,
        choose_category(ChosenCategory)
    ).

% Manages the word guessing, checking if the guesses are correct
guess_word(ActualWord, RequiredLength, Guesses):-
    (
        Guesses = 0 ->  % Check if no guesses are left
        write('You lost!'), nl
    ;
        write('Enter a word composed of '), write(RequiredLength), write(' letters:'), nl,
        read(GuessWord),
        (
            var(GuessWord) ->  % Ensure the guess is not a variable
            write('Variables are not allowed, please try again.'), nl,
            guess_word(ActualWord, RequiredLength, Guesses)
            ;
            (
                GuessWord = ActualWord ->  % Check if the guess is correct
                write('You won!'), nl
                ;
                atom_length(GuessWord, RequiredLength),  % Validate the length of the guess
                atom_chars(ActualWord, ActualLetters),
                atom_chars(GuessWord, GuessLetters),
                correct_letters(ActualLetters, GuessLetters, CorrectLetters),
                correct_positions(ActualLetters, GuessLetters, CorrectPositions),
                write('Correct letters are: '), write(CorrectLetters), nl,
                write('Correct letters in correct positions are: '), write(CorrectPositions), nl,
                NewGuesses is Guesses - 1,
                write('Remaining Guesses are '), write(NewGuesses), nl, nl,
                guess_word(ActualWord, RequiredLength, NewGuesses)
            )
        )
    ).

% Validate the length choice by the player
choose_length(Length, Category):-
    write('Choose a length: '), nl,
    read(LengthChoice),
    (
        var(LengthChoice),  % Check if the input is a variable
        write('Variables are not allowed, please try again.'), nl,
        choose_length(Length, Category)
    ;
        \+integer(LengthChoice),  % Check if the input is an integer
        write('You must enter a number, try again.'), nl,
        choose_length(Length, Category)
    ;
        pick_word(_, LengthChoice, Category),  % Check if there is any word of that length
        Length = LengthChoice
    ;
        write('There are no words of this length. '), nl,
        choose_length(Length, Category)
    ).

% Functions to determine correct letters and their positions
correct_positions([], [], []).
correct_positions([H|T1], [H|T2], [H|T3]):-
    correct_positions(T1, T2, T3).
correct_positions([H1|T1], [H2|T2], T3):-
    H1 \= H2,
    correct_positions(T1, T2, T3).

correct_letters(ActualLetters, GuessLetters, CorrectLetters):-
    intersection(GuessLetters, ActualLetters, CorrectLettersList),
    list_to_set(CorrectLettersList, CorrectLetters).

% Check if a given category exists
is_category(Category):-
    word(_, Category).

% Retrieve all categories from the knowledge base
categories(CategoryList):-
    setof(Category, is_category(Category), CategoryList).

% Retrieve all available word lengths from the knowledge base
available_length(Length):-
    word(Word, _),
    atom_length(Word, Length).
