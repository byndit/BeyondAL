page 50002 "BIT Editor"
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

    trigger OnOpenPage()
    begin
        xEditorText := EditorText;
    end;

    procedure GetText(): Text
    begin
        exit(EditorText);
    end;

    procedure GetxText(): Text
    begin
        exit(xEditorText);
    end;

    procedure SetText(NewEditorText: Text)
    begin
        EditorText := NewEditorText;
    end;


    var
        EditorText: Text;
        xEditorText: Text;
}

