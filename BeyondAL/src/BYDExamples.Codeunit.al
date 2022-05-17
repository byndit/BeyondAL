codeunit 50002 "BYD Examples Mgt."
{
    procedure DownloadPDFfromURL()
    var
        Instr: InStream;
        Filename: Text;
        Url: Text;
    begin
        Filename := 'BEYONDCloudConnector.pdf';
        Url := 'https://en.beyond-cloudconnector.de/_files/ugd/96eaf6_16d4b7b24ce249339594fb661dbb7f48.pdf';
        BYDWebRequestMgt.ResponseAsInStr(Instr, BYDWebRequestMgt.PerformWebRequest(Url, Enum::"BYD Web Request Method"::GET));
        DownloadFromStream(Instr, SaveFileDialogTitleMsg, '', SaveFileDialogFilterMsg, Filename);
    end;

    procedure ViewImagefromURL()
    var
        Base64Convert: Codeunit "Base64 Convert";
        BYDEditor: Page "BYD Editor";
        BYDViewer: Page "BYD Viewer";
        Instr: InStream;
        Base64: Text;
        Url: Text;
    begin
        Clear(BYDEditor);
        BYDEditor.LookupMode := true;
        if BYDEditor.RunModal() <> Action::LookupOK then
            exit;
        Url := BYDEditor.GetText();
        BYDWebRequestMgt.ResponseAsInStr(Instr, BYDWebRequestMgt.PerformWebRequest(Url, Enum::"BYD Web Request Method"::GET));
        Base64 := Base64Convert.ToBase64(Instr);

        Clear(BYDViewer);
        BYDViewer.SetVariables(url, Base64);
        BYDViewer.Run();
    end;

    var
        BYDWebRequestMgt: Codeunit "BYD Web Request Mgt.";
        SaveFileDialogFilterMsg: Label 'PDF Files (*.pdf)|*.pdf';
        SaveFileDialogTitleMsg: Label 'Save PDF file';
}