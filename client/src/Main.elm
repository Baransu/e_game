module Main exposing (..)

import Html exposing (Html, h3, div, text, ul, li, input, form, button, br, table, tbody, tr, td)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onInput, onSubmit, onClick)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Json.Encode as JE
import Json.Decode as JD exposing (field, list)
import Dict


-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- CONSTANTS


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"



-- MODEL


type Msg
    = SendMessage
    | SetNewMessage String
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ReceiveChatMessage JE.Value
    | ReceiveMessages JE.Value
    | JoinChannel
    | LeaveChannel
    | ShowLeftMessage String
    | NoOp
    | Any JE.Value


type alias Model =
    { newMessage : String
    , messages : List String
    , phxSocket : Phoenix.Socket.Socket Msg
    }


initPhxSocket : Phoenix.Socket.Socket Msg
initPhxSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "new:msg" "room:lobby" ReceiveChatMessage
        |> Phoenix.Socket.on "push:image" "room:lobby" Any


initModel : Model
initModel =
    Model "" [] initPhxSocket


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg



-- COMMANDS
-- PHOENIX STUFF


type alias ChatMessage =
    { user : String
    , body : String
    }


type alias Location =
    { x : Float
    , y : Float
    }


chatMessageDecoder : JD.Decoder ChatMessage
chatMessageDecoder =
    JD.map2 ChatMessage
        (field "user" JD.string)
        (field "body" JD.string)


chatMessagesDecoder : JD.Decoder (List ChatMessage)
chatMessagesDecoder =
    field "messages" <| list chatMessageDecoder


locationsDecoder : JS.Decoder (List Location)
locationsDecoder =
    field "locations" <|
        list JD.map2
            Location
            (field "x" JD.float)
            (field "y" JD.float)


handleSocket : Model -> ( Phoenix.Socket.Socket Msg, Cmd (Phoenix.Socket.Msg Msg) ) -> ( Model, Cmd Msg )
handleSocket model ( phxSocket, phxCmd ) =
    { model | phxSocket = phxSocket } ! [ Cmd.map PhoenixMsg phxCmd ]



-- UPDATE


formatMessage : ChatMessage -> String
formatMessage { user, body } =
    user ++ ": " ++ body


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Any raw ->
            let
                v =
                    Debug.log "locations" <|
                        case JD.decodeValue chatMessageDecoder raw of
                            Ok chatMessage ->
                                Just chatMessage

                            Err error ->
                                Nothing
            in
                model ! []

        PhoenixMsg msg ->
            handleSocket model <| Phoenix.Socket.update msg model.phxSocket

        SendMessage ->
            let
                payload =
                    (JE.object [ ( "user", JE.string "user" ), ( "body", JE.string model.newMessage ) ])

                push_ =
                    Phoenix.Push.init "new:msg" "room:lobby"
                        |> Phoenix.Push.withPayload payload

                socketUpdate =
                    Phoenix.Socket.push push_ model.phxSocket
            in
                handleSocket { model | newMessage = "" } socketUpdate

        SetNewMessage str ->
            { model | newMessage = str } ! []

        ReceiveChatMessage raw ->
            case JD.decodeValue chatMessageDecoder raw of
                Ok chatMessage ->
                    { model | messages = formatMessage chatMessage :: model.messages } ! []

                Err error ->
                    model ! []

        JoinChannel ->
            let
                channel =
                    Phoenix.Channel.init "room:lobby"
                        |> Phoenix.Channel.onJoin ReceiveMessages
                        |> Phoenix.Channel.onClose (always (ShowLeftMessage "room:lobby"))

                socketUpdate =
                    Phoenix.Socket.join channel model.phxSocket
            in
                handleSocket model socketUpdate

        LeaveChannel ->
            let
                socketUpdate =
                    Phoenix.Socket.leave "room:lobby" model.phxSocket
            in
                handleSocket model socketUpdate

        ReceiveMessages raw ->
            case JD.decodeValue chatMessagesDecoder raw of
                Ok messages ->
                    { model | messages = List.map formatMessage messages } ! []

                Err error ->
                    model ! []

        ShowLeftMessage channelName ->
            { model | messages = ("Left channel " ++ channelName) :: model.messages } ! []

        NoOp ->
            model ! []



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h3 [] [ text "Channels:" ]
        , div
            []
            [ button [ onClick JoinChannel ] [ text "Join channel" ]
            , button [ onClick LeaveChannel ] [ text "Leave channel" ]
            ]
        , channelsTable (Dict.values model.phxSocket.channels)
        , br [] []
        , h3 [] [ text "Messages:" ]
        , newMessageForm model
        , ul [] ((List.reverse << List.map renderMessage) model.messages)
        ]


channelsTable : List (Phoenix.Channel.Channel Msg) -> Html Msg
channelsTable channels =
    table []
        [ tbody [] (List.map channelRow channels)
        ]


channelRow : Phoenix.Channel.Channel Msg -> Html Msg
channelRow channel =
    tr []
        [ td [] [ text channel.name ]
        , td [] [ (text << toString) channel.payload ]
        , td [] [ (text << toString) channel.state ]
        ]


newMessageForm : Model -> Html Msg
newMessageForm model =
    form [ onSubmit SendMessage ]
        [ input [ type_ "text", value model.newMessage, onInput SetNewMessage ] []
        ]


renderMessage : String -> Html Msg
renderMessage str =
    li [] [ text str ]
