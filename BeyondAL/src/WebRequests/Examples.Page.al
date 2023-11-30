page 50000 "BIT Examples"
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
                ToolTip = 'Executes the Download a PDF file from URL action.';
                trigger OnAction()
                var
                    BITExamplesMgt: Codeunit "BIT Examples Mgt.";
                begin
                    BITExamplesMgt.DownloadPDFfromURL();
                end;
            }
            action(ImportRecordLinks)
            {
                ApplicationArea = All;
                Caption = 'Import Record Links';
                Image = Import;
                ToolTip = 'Executes the Import Record Links action.';
                trigger OnAction()
                var
                    Links: Codeunit "BIT Import Record Links";
                begin
                    Links.Run();
                end;
            }

            action(ShowImage)
            {
                ApplicationArea = All;
                Caption = 'Show a picture from URL in a separate Page';
                Image = ShowList;
                ToolTip = 'Executes the Show a picture from URL in a separate Page action.';
                trigger OnAction()
                var
                    BITExamplesMgt: Codeunit "BIT Examples Mgt.";
                begin
                    BITExamplesMgt.ViewImagefromURL();
                end;
            }
        }
    }


}