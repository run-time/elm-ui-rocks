# elm-ui-rocks
Learning to use elm-ui by building a simple rock, paper, scissors game

`git clone https://github.com/run-time/elm-ui-rocks.git`

`cd elm-ui-rocks`

`elm-ui install`

`elm-ui server`

[http://localhost:8002](http://localhost:8002)


# GOALS
 - Fix the score to keep a running total of wins / losses
 - Fix game results to show notifications after each button click
 - Add buttons for Lizard and Spock
 - Show instructions on initial page load

# ELM INTRO

The Elm programming language has too many awesome features to list here so work your way through the docs at  --  http://elm-lang.org/docs

Here are my 3 favorite things about Elm so far...

  1. Everything is a function!  (okay, not really but all the good stuff is)
     Even my favorite number 4 is a function which always returns a number and
     that number always happens to be my favorite number.  How cool is that?!

     Run elm-repl from a terminal window to test it out...
     ```
       > 4
       4 : number
       > four = 4
       4 : number
       > four
       4 : number
     ```

  2. Zero run-time errors!
     Since Elm is a strongly typed language it won't compile down to JavaScript
     if there are any ambiguities in the code.


  3. Currying is built-in to the language!
     Currying is so fundamental to functional programming Elm does it using the
     best interface ever -- whitespace!  I often say, "the best UI is no UI" and
     although Elm is rigid when it comes to actual data-types the type syntax is
     clean and flexible.

     We can define an Elm function which adds two numbers together like so...
     ```
       add : number -> number -> number
       add a b =
         a + b
     ```

     Although the arrow type system in Elm may seem a little peculiar at first
     it is one of my favorite things about the syntax.  The function return type
     is always at the end so in this case our function actually has 3 return
     types depending on how it's called!

     If we pass in two numbers add returns a number
     If we pass in one number add returns a number -> number
     If we pass in zero numbers add returns a number -> number -> number

     It's time to break out the elm-repl again...
     ```
       > add
       <function> : number -> number -> number
       > add 1
       <function> : number -> number
       > add 2 3
       5 : number
     ```

     It takes some practice using small functions to create bigger and bigger
     functions but the Elm syntax can really help lower the barrier to entry.

     Let's see an example starting with our fundamental add function...
     ```
       increment : number -> number
       increment a =
         add a 1
     ```

     Using the elm-repl we can see this in action...
     ```
       > increment
       <function> : number -> number
       > increment 3
       4 : number
     ```

     And we can also see that even the + operator is just a function!
     ```
       > (+)
       <function> : number -> number -> number
       > (+) 2 2
       4 : number
     ```

     Which brings us back to   --  1. Everything is a function!
     
