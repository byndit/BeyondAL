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