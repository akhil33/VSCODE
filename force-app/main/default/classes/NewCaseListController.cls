public class NewCaseListController {
    public List<Case> getNewCases(){
        List<Case> listcase = new List<Case>([SELECT id, CaseNumber FROM Case where status ='New']);
        Return listcase;
    }
}