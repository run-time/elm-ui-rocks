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
  | SendNotification


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

    SendNotification ->
      notify model


updatePlayerChoice : String -> Model -> (Model, Effects.Effects Action)
updatePlayerChoice choice model =
  let
    ( newRand, newSeed ) =
      Random.generate (Random.int 0 2) model.seed
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
  Maybe.withDefault "error" ( Array.get i (Array.fromList ["rock","paper","scissors"]) )


choiceToInt : String -> Int
choiceToInt s =
  case s of
  "rock" -> 0
  "paper" -> 1
  "scissors" -> 2
  _ -> -1


getResult : (Int, Int) -> (Int, String)
getResult (player, cpu) =
  case (player, cpu) of
    (0, 1) -> (-1, "Paper covers Rock")
    (0, 2) -> (1, "Rock crushes Scissors")

    (1, 0) -> (1, "Paper covers Rock")
    (1, 2) -> (-1, "Scissors cuts Paper")

    (2, 0) -> (-1, "Rock crushes Scissors")
    (2, 1) -> (1, "Scissors cuts Paper")

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
          , text " Rocks... Paper, Scissors"
          ]
      , Ui.Container.row []
        [ div [ class "button-list" ]
          [ Ui.Button.primary "Rock" address Rock
          , Ui.Button.primary "Paper" address Paper
          , Ui.Button.primary "Scissors" address Scissors
          , Ui.Button.secondary "Game Result?" address SendNotification
          ]
        ]
      , Ui.Container.row []
        [ div [ class ("card " ++ (model.playerChoice)) ] []
        , div [ class ("card " ++ (model.cpuChoice)) ] []
        ]
      , Ui.Container.row []
        [ div [ class "score-card" ]
          [ text ("Score: " ++ (toString model.score)) ]
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
