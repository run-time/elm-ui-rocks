{-------------------------------------------------------------------------------
WELCOME TO ELM!
--------------------------------------------------------------------------------
The Elm programming language has too many awesome features to list here so
you can work your way through the docs at  --  http://elm-lang.org/docs

Here are my 3 favorite things about Elm so far...

  1. Everything is a function!
     Even my favorite number 4 is a function which always returns a number and
     that number always happens to be my favorite number.  How cool is that?!

     Run elm-repl from a terminal window to test things out...
       > 4
       4 : number
       > four = 4
       4 : number
       > four
       4 : number


  2. Zero run-time errors!
     Since Elm is a strongly typed language it won't compile down to JavaScript
     if there are any ambiguities in the code.


  3. Currying is built-in to the language!
     Currying is so fundamental to functional programming Elm does it using the
     best interface ever -- whitespace!  I often say, "the best UI is no UI" and
     although Elm is rigid when it comes to actual data-types the type syntax is
     clean and flexible.

     We can define an Elm function which adds two numbers together like so...
       add : number -> number -> number
       add a b =
         a + b

     Although the arrow type system in Elm may seem a little peculiar at first
     it is one of my favorite things about the syntax.  The function return type
     is always at the end so in this case our function actually has 3 return
     types depending on how it's called!

     If we pass in two numbers add returns a number
     If we pass in one number add returns a number -> number
     If we pass in zero numbers add returns a number -> number -> number

     It's time to break out the elm-repl again...
       > add
       <function> : number -> number -> number
       > add 1
       <function> : number -> number
       > add 2 3
       5 : number

     It takes some practice using small functions to create bigger and bigger
     functions but the Elm syntax can really help lower the barrier to entry.

     Let's see an example starting with our fundamental add function...
       increment : number -> number
       increment a =
         add a 1

    Using the elm-repl we can see this in action...
       > increment
       <function> : number -> number
       > increment 3
       4 : number

    And we can also see that even the + operator is just a function!
      > (+)
      <function> : number -> number -> number
      > (+) 2 2
      4 : number

    Which brings us back to   --  1. Everything is a function!
-------------------------------------------------------------------------------}

module Main where

{-------------------------------------------------------------------------------
1. LIST ALL DEPENDENCIES
--------------------------------------------------------------------------------
Import modules up top and expose only the functions you need for each module.

Note: you can expose everything in a module by typing -- exposing (..) however
this increases your chances of naming collisions so be careful.
-------------------------------------------------------------------------------}
import StartApp
import Effects
import Task
import Signal exposing
  ( forwardTo
  , Address
  )
import Html exposing
  ( Html
  , div
  , span
  , strong
  , text
  , a
  , p
  , button
  )
import Html.Attributes exposing
  ( class
  , style
  , href
  )

import Array exposing (..)
import Random exposing (Seed)

import Ui.NotificationCenter
import Ui.Container
import Ui.Button
import Ui.App
import Ui






{-------------------------------------------------------------------------------
2. MODEL
--------------------------------------------------------------------------------
Define your App data Model, Actions, and initial state here
-------------------------------------------------------------------------------}
type alias Model =
  { app : Ui.App.Model
  , notifications : Ui.NotificationCenter.Model
  , seed : Seed
  , randInt : Int
  , playerChoice : String
  , cpuChoice : String
  , gameResult : String
  }

init : Model
init =
  { app = Ui.App.init "Elm-UI Rocks!"
  , notifications = Ui.NotificationCenter.init 4000 320
  , seed = Random.initialSeed 97  --(round startTime)
  , randInt = -1
  , playerChoice = ""
  , cpuChoice = ""
  , gameResult = ""
  }




{-------------------------------------------------------------------------------
3. UPDATE
--------------------------------------------------------------------------------
Model update functions go here (a.k.a. controllers / business logic)
-------------------------------------------------------------------------------}
type Action
  = App Ui.App.Action
  | Notices Ui.NotificationCenter.Action
  | GenerateNewNumber
  | Rock
  | Paper
  | Scissors
  | Lizard
  | Spock
  | ShowNotification


update : Action -> Model -> (Model, Effects.Effects Action)
update action model =
  case action of
    App act ->
      let
        (app, effect) = Ui.App.update act model.app
      in
        ({ model | app = app }, Effects.map App effect)

    Notices act ->
      let
        (notices, effect) = Ui.NotificationCenter.update act model.notifications
      in
        ({ model | notifications = notices }, Effects.map Notices effect)

    GenerateNewNumber ->
      let
        ( newRand, newSeed ) =
          Random.generate (Random.int 0 4) model.seed
      in
        ({ model | seed = newSeed, randInt = newRand }, Effects.none)

    Rock ->
      updatePlayerChoice "rock" model

    Paper ->
      updatePlayerChoice "paper" model

    Scissors ->
      updatePlayerChoice "scissors" model

    Lizard ->
      updatePlayerChoice "lizard" model

    Spock ->
      updatePlayerChoice "spock" model

    ShowNotification ->
      notify "Spock" model





updatePlayerChoice : a -> { e | cpuChoice : b, playerChoice : c, randInt : d, seed : Seed } -> ( { e | cpuChoice : String, playerChoice : a, randInt : Int, seed : Seed }, Effects.Effects f )
updatePlayerChoice choice model =
  let
    ( newRand, newSeed ) =
      Random.generate (Random.int 0 4) model.seed
  in
    ({ model |
      playerChoice = choice
      , seed = newSeed
      , randInt = newRand
      , cpuChoice = (intToChoice newRand)
      }, Effects.none)


intToChoice : Int -> String
intToChoice i =
  Maybe.withDefault "error" ( Array.get i (Array.fromList ["rock","paper","scissors","lizard","spock"]) )

possibleResults : List String
possibleResults =
  [ "Scissors cuts Paper"
  , "Paper covers Rock"
  , "Rock crushes Lizard"
  , "Lizard poisons Spock"
  , "Spock disassembles Scissors"
  , "Scissors decapitates Lizard"
  , "Lizard eats Paper"
  , "Paper disproves Spock"
  , "Spock vaporizes Rock"
  , "Rock crushes Scissors"
  ]

{-------------------------------------------------------------------------------
4. VIEW
--------------------------------------------------------------------------------
The view function uses an Action and Model to render all the Html
The app function passes a config record to StartApp.start
The main function is the starting point for all Elm applications
-------------------------------------------------------------------------------}
view : Signal.Address Action -> Model -> Html.Html
view address model =
  Ui.App.view (forwardTo address App) model.app
    [ Ui.NotificationCenter.view (forwardTo address Notices) model.notifications
    , Ui.Container.column []
      [ Ui.title []
          [ a [ href "https://github.com/gdotdesign/elm-ui" ] [ text "Elm-UI" ]
          , text " Rocks... Paper, Scissors, Lizard, Spock"
          ]
      , Ui.Container.row []
        [ div [ class "button-list" ]
          [ Ui.Button.primary "Rock" address Rock
          , Ui.Button.primary "Paper" address Paper
          , Ui.Button.primary "Scissors" address Scissors
          , Ui.Button.primary "Lizard" address Lizard
          , Ui.Button.primary "Spock" address Spock
          , Ui.Button.primary "Show Notification" address ShowNotification
          ]
        ]
      , Ui.Container.row []
        [ div [ class ("card " ++ (model.playerChoice)) ] []
        , div [ class ("card " ++ (model.cpuChoice)) ] []
        ]
      ]
    ]


notify : String -> Model -> (Model, Effects.Effects Action)
notify message model =
  let
    (notices, effect) = Ui.NotificationCenter.notify (text message) model.notifications
  in
    ({ model | notifications = notices }, Effects.map Notices effect)


app : StartApp.App Model
app =
  StartApp.start
    { init = (init, Effects.none)
    , update = update
    , view = view
    , inputs = []
    }

main : Signal Html
main =
  app.html



{-------------------------------------------------------------------------------
5. PORTS
--------------------------------------------------------------------------------
In general, ports provide two-way communication between JavaScript and Elm
StartApp uses app.tasks to run a signal of tasks generated from events
-------------------------------------------------------------------------------}
port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks

--port startTime : Float
