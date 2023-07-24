codeunit 50008 "ABC Custom Filter Token"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Filter Tokens", 'OnResolveTextFilterToken', '', true, true)]
    local procedure FilterMySalesperson(TextToken: Text; var TextFilter: Text; var Handled: Boolean)
    var
        UserSetup: Record "User Setup";
        SPNTok: Label 'SPN', Locked = true;
    begin
        if not UserSetup.Get(UserId()) then
            exit;

        if UserSetup."Salespers./Purch. Code" = '' then
            exit;

        if StrLen(TextToken) < 3 then
            exit;

        if StrPos(UpperCase(SPNTok), UpperCase(TextToken)) = 0 then
            exit;

        Handled := true;

        TextFilter := UserSetup."Salespers./Purch. Code";
    end;
}
