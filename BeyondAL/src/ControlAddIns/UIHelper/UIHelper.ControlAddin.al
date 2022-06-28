controladdin "BIT UI Helper"
{
    MinimumWidth = 1;
    MinimumHeight = 1;
    RequestedHeight = 1;
    RequestedWidth = 1;
    MaximumWidth = 1;
    MaximumHeight = 1;

    VerticalStretch = false;
    VerticalShrink = false;
    HorizontalStretch = false;
    HorizontalShrink = false;

    StartupScript = './src/ControlAddIns/UIHelper/js/startup.js';
    Scripts = './src/ControlAddIns/UIHelper/js/main.js';

    event OnControlReady();
    event OnError(errorTxt: Text)
    event Pong();
    event OnKeyPressed(KeyString: Text);
    procedure Ping(timems: Integer);
    procedure CopyToClipboard(input: Text);
}