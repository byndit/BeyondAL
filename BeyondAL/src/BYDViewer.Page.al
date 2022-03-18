page 50001 "BYD Viewer"
{
    Caption = 'Viewer';
    PageType = Card;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(ViewerGroup)
            {
                ShowCaption = false;
                usercontrol(BYDPreview; "BYD Preview")
                {
                    ApplicationArea = All;
                    trigger ControlReady()
                    begin
                        LoadFile();
                    end;
                }
            }
        }
    }

    local procedure LoadFile()
    begin
        CurrPage.BYDPreview.LoadFile(Base64);
    end;

    procedure SetVariables(Url: text; NewBase64: Text)
    var
        FileManagement: Codeunit "File Management";
    begin
        Base64 := StrSubstNo('data:%1;base64,%2', FileManagement.GetFileNameMimeType(url), NewBase64);
    end;

    var
        Base64: Text;
}