global class BAT_FscExtractFull implements Database.Batchable<sObject>, Database.Stateful{
    public String query;  
    global String objRowStr; 
    global String attachmentHeader;
    global List<String> csvRowValues = new List<String>();
    global String finalString;
    global BAT_FscExtractFull (String query){
        this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<permissionset > PS = [SELECT Id,PermissionSet.Profile.Name FROM permissionset WHERE IsOwnedByProfile = true];
        
        Map <Id, String> PsToProfileNameMap = New Map<Id, String>();
        For(permissionset ps_Var: PS){
            PsToProfileNameMap.put(ps_Var.Id, ps_Var.Profile.Name);
        }
        
        Map<String, Map<String, String>> fscMap = HDL_FSCextract.generateProfileMap(scope, PsToProfileNameMap);
        String stringUnprocessed = HDL_FSCextract.generateCsvMainString(fscMap,HDL_FSCextract.fieldNameSet );
        finalString = HDL_FSCextract.generateFinalString(fscMap.Keyset(), stringUnprocessed);
        
    }
    
    global void finish(Database.BatchableContext BC){
        List<Folder> folders = [SELECT Id, Name FROM Folder WHERE Name = 'FSC_logs'];
        String documentName = 'FieldLevel Security-'+ Datetime.now().format('MMM') + Datetime.now().year();
        if(!folders.isEmpty()){
            Document doc = new Document(Name = documentName, 
                                        Body = Blob.valueOf(finalString), 
                                        FolderId = folders[0].Id, 
                                        Type = 'csv', 
                                        ContentType='application/vnd.ms-excel'
                                       );
            insert doc;
        }
    }
}