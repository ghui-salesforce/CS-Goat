public class myCustomController {
    private final Account account;
    public myCustomController(){
        account = [SELECT id,name,description FROM Account
                   WHERE id=:ApexPages.currentPage().getParameters().get('id')];
    
    }
    public Account getAccount(){
        return account;
    }
    public PageReference save(){
        update account;
        return null;
    }
}