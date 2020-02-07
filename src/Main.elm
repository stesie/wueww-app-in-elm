module Main exposing (main)

import Browser
import Html


type alias Model =
    { sessions : Maybe (List Session)
    }


type alias Session =
    { title : String
    }


type Msg
    = Foo
    | Bar


init : () -> ( Model, Cmd Msg )
init _ =
    ( { sessions = Nothing }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


view : Model -> Browser.Document Msg
view _ =
    { title = "Hello World"
    , body = [ Html.div [] [ Html.text "Hello World balrg" ] ]
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
