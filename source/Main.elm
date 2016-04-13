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

import Array exposing
  ( get
  , fromList
  )

import Random exposing
  ( Seed
  )

import Date exposing
  ( millisecond
  )

import Ext.Date

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
  , gameResult : (Int, String)
  , score : Int
  }

init : Model
init =
  { app = Ui.App.init "Elm-UI Rocks!"
  , notifications = Ui.NotificationCenter.init 4000 320
  , seed = Random.initialSeed ( millisecond (Ext.Date.now ()) )
  , randInt = -1
  , playerChoice = ""
  , cpuChoice = ""
  , gameResult = (0, "")
  , score = 0
  }



{-------------------------------------------------------------------------------
3. UPDATE
--------------------------------------------------------------------------------
Model update functions go here (a.k.a. controllers / business logic)
-------------------------------------------------------------------------------}
type Action
  = App Ui.App.Action
  | Notices Ui.NotificationCenter.Action
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
      notify model


updatePlayerChoice : String -> { e | cpuChoice : a, gameResult : b, playerChoice : c, randInt : d, seed : Seed } -> ( { e | cpuChoice : String, gameResult : ( Int, String ), playerChoice : String, randInt : Int, seed : Seed}, Effects.Effects f)
updatePlayerChoice choice model =
  let
    ( newRand, newSeed ) =
      Random.generate (Random.int 0 4) model.seed
  in
    ({ model
      | seed = newSeed
      , randInt = newRand
      , cpuChoice = (intToChoice newRand)
      , playerChoice = choice
      , gameResult = getResult ((choiceToInt choice), newRand)
      }, Effects.none)


intToChoice : Int -> String
intToChoice i =
  Maybe.withDefault "error" ( Array.get i (Array.fromList ["rock","paper","scissors","lizard","spock"]) )


choiceToInt : String -> Int
choiceToInt s =
  case s of
  "rock" -> 0
  "paper" -> 1
  "scissors" -> 2
  "lizard" -> 3
  "spock" -> 4
  _ -> -1


getResult : (Int, Int) -> (Int, String)
getResult (player, cpu) =
  case (player, cpu) of
    (0, 1) -> (-1, "Paper covers Rock")
    (0, 2) -> (1, "Rock crushes Scissors")
    (0, 3) -> (1, "Rock smashes Lizard")
    (0, 4) -> (-1, "Spock vaporizes Rock")

    (1, 0) -> (1, "Paper covers Rock")
    (1, 2) -> (-1, "Scissors cuts Paper")
    (1, 3) -> (-1, "Lizard eats Paper")
    (1, 4) -> (1, "Paper disproves Spock")

    (2, 0) -> (-1, "Rock crushes Scissors")
    (2, 1) -> (1, "Scissors cuts Paper")
    (2, 3) -> (1, "Scissors decapitates Lizard")
    (2, 4) -> (-1, "Spock disassembles Scissors")

    (3, 0) -> (-1, "Rock smashes Lizard")
    (3, 1) -> (1, "Lizard eats Paper")
    (3, 2) -> (-1, "Scissors decapitates Lizard")
    (3, 4) -> (1, "Lizard poisons Spock")

    (4, 0) -> (1, "Spock vaporizes Rock")
    (4, 1) -> (-1, "Paper disproves Spock")
    (4, 2) -> (1, "Spock disassembles Scissors")
    (4, 3) -> (-1, "Lizard poisons Spock")

    _ -> (0, "TIE")


notify : Model -> (Model, Effects.Effects Action)
notify model =
  let
    (notices, effect) = Ui.NotificationCenter.notify (getNotificationHtml model) model.notifications
  in
    ({ model | notifications = notices }, Effects.map Notices effect)


getNotificationHtml : Model -> Html
getNotificationHtml model =
  case ( fst model.gameResult ) of
    (1) -> (div [ class "win" ] [ text ( snd model.gameResult ) ])
    (-1) -> (div [ class "lose" ] [ text ( snd model.gameResult ) ])
    (0) -> (text ( snd model.gameResult ))
    _ -> (text "error")


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
          , Ui.Button.secondary "Show Notification" address ShowNotification
          ]
        ]
      , Ui.Container.row []
        [ div [ class ("card " ++ (model.playerChoice)) ] []
        , div [ class ("card " ++ (model.cpuChoice)) ] []
        ]
      , Ui.Container.row []
        [ div [ class "score-card" ] [ text ("Score: " ++ (toString model.score)) ]
        ]
      ]
    ]

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
