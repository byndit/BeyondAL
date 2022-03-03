codeunit 50002 "BYD Examples Mgt."
{
    procedure DownloadPDFfromURL()
    var
        Instr: InStream;
        Filename: Text;
    begin
        Filename := 'BEYONDCloudConnector.pdf';
        BYDWebRequestMgt.ResponseAsInStr(Instr, BYDWebRequestMgt.PerformWebRequest('https://en.beyond-cloudconnector.de/_files/ugd/96eaf6_16d4b7b24ce249339594fb661dbb7f48.pdf', Enum::"BYD Web Request Method"::GET));
        DownloadFromStream(Instr, SaveFileDialogTitleMsg, '', SaveFileDialogFilterMsg, Filename);
    end;

    var
        BYDWebRequestMgt: Codeunit "BYD Web Request Mgt.";
        SaveFileDialogFilterMsg: Label 'PDF Files (*.pdf)|*.pdf';
        SaveFileDialogTitleMsg: Label 'Save PDF file';
}