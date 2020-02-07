module Main exposing (main)

import Browser
import Html exposing (..)
import Http
import Json.Decode as D


type alias Model =
    { sessions : Maybe (List Session)
    }


type alias Session =
    { title : String
    }


type Msg
    = SetSessions (Result Http.Error (List Session))


fetchSessions : Cmd Msg
fetchSessions =
    Http.get
        { url = "https://backend.timetable.wueww.de/export/session.json"
        , expect = Http.expectJson SetSessions sessionsFileDecoder
        }


sessionsFileDecoder : D.Decoder (List Session)
sessionsFileDecoder =
    let
        sessionDecoder : D.Decoder Session
        sessionDecoder =
            D.map Session (D.field "title" D.string)
    in
    D.field "sessions" (D.list sessionDecoder)


init : () -> ( Model, Cmd Msg )
init _ =
    ( { sessions = Nothing }, fetchSessions )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetSessions (Ok sessions) ->
            ( { model | sessions = Just sessions }, Cmd.none )

        SetSessions (Err _) ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Hello World"
    , body =
        [ case model.sessions of
            Nothing ->
                text "Daten werden geladen ..."

            Just sessions ->
                ul [] (List.map (\session -> li [] [ text session.title ]) sessions)
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
