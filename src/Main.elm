module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Decode as D
import List.Extra exposing (remove)


type alias Model =
    { sessions : Maybe (List Session)
    , expandedSessionIds : List Int
    }


type alias Session =
    { id : Int
    , title : String
    }


type Msg
    = SetSessions (Result Http.Error (List Session))
    | ExpandSession Int
    | CollapseSession Int


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
            D.map2 Session (D.field "id" D.int) (D.field "title" D.string)
    in
    D.field "sessions" (D.list sessionDecoder)


init : () -> ( Model, Cmd Msg )
init _ =
    ( { sessions = Nothing
      , expandedSessionIds = []
      }
    , fetchSessions
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetSessions (Ok sessions) ->
            ( { model | sessions = Just sessions }, Cmd.none )

        SetSessions (Err _) ->
            ( model, Cmd.none )

        ExpandSession id ->
            ( { model | expandedSessionIds = id :: model.expandedSessionIds }, Cmd.none )

        CollapseSession id ->
            ( { model | expandedSessionIds = remove id model.expandedSessionIds }, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Hello World"
    , body =
        [ case model.sessions of
            Nothing ->
                text "Daten werden geladen ..."

            Just sessions ->
                div [ A.class "ui container body" ]
                    [ div [ A.class "ui doubling two cards" ]
                        (List.map
                            (\session ->
                                let
                                    isExpanded =
                                        List.member session.id model.expandedSessionIds

                                    chevronDirection =
                                        if isExpanded then
                                            "down"

                                        else
                                            "right"
                                in
                                div [ A.class "ui card" ]
                                    [ div [ A.class "content" ]
                                        [ div
                                            [ A.class "header"
                                            , E.onClick
                                                (if isExpanded then
                                                    CollapseSession session.id

                                                 else
                                                    ExpandSession session.id
                                                )
                                            ]
                                            [ span [ A.class "right floated" ] [ i [ A.class "chevron icon", A.class chevronDirection ] [] ]
                                            , text session.title
                                            ]
                                        ]
                                    ]
                            )
                            sessions
                        )
                    ]
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
