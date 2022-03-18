page 50002 "BYD Editor"
{
    UsageCategory = None;
    Caption = 'Editor';
    PageType = Card;

    layout
    {
        area(content)
        {
            grid(Editor)
            {
                ShowCaption = false;
                field(EditorText; EditorText)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ShowCaption = false;
                }
            }
        }
    }
    procedure GetText(): Text
    begin
        exit(EditorText);
    end;

    var
        EditorText: Text;
}

