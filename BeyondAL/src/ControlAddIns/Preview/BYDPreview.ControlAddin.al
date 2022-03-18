controladdin "BYD Preview"
{
    Scripts = 'src/ControlAddIns/Preview/js/master.js';
    StartupScript = 'src/ControlAddIns/Preview/js/starting.js';

    HorizontalStretch = true;
    HorizontalShrink = true;
    VerticalShrink = true;
    VerticalStretch = true;
    MinimumWidth = 400;
    MinimumHeight = 650;
    RequestedWidth = 400;
    RequestedHeight = 1650;
    event ControlReady();
    procedure LoadFile(url: Text);
}