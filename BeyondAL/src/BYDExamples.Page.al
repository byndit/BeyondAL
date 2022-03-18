page 50000 "BYD Examples"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Integer;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DownloadPDF)
            {
                ApplicationArea = All;
                Caption = 'Download a PDF file from URL';
                Image = Download;

                trigger OnAction()
                var
                    BYDExamplesMgt: Codeunit "BYD Examples Mgt.";
                begin
                    BYDExamplesMgt.DownloadPDFfromURL();
                end;
            }
            action(ShowImage)
            {
                ApplicationArea = All;
                Caption = 'Show a picture from URL in a separate Page';
                Image = ShowList;

                trigger OnAction()
                var
                    BYDExamplesMgt: Codeunit "BYD Examples Mgt.";
                begin
                    BYDExamplesMgt.ViewImagefromURL();
                end;
            }
        }
    }


}