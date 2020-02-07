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
    , description : Description
    }


type alias Description =
    { long : String
    , short : Maybe String
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


descriptionDecoder : D.Decoder Description
descriptionDecoder =
    D.map2 Description
        (D.field "long" D.string)
        (D.maybe (D.field "short" D.string))


sessionsFileDecoder : D.Decoder (List Session)
sessionsFileDecoder =
    let
        sessionDecoder : D.Decoder Session
        sessionDecoder =
            D.map3 Session (D.field "id" D.int) (D.field "title" D.string) (D.field "description" descriptionDecoder)
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

                                    descriptionText =
                                        case session.description.short of
                                            Just value ->
                                                value

                                            Nothing ->
                                                session.description.long

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
                                    , if isExpanded then
                                        div [ A.class "extra content" ]
                                            [ div [ A.class "description" ]
                                                [ text descriptionText
                                                ]
                                            ]

                                      else
                                        text ""
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
